extends Node

const SERVER_URL = "ws://192.168.1.1:8000/xiaozhi/v1"
const AUDIO_FRAME_MS = 60  # 每帧音频时长（毫秒）
signal is_talking
signal emotion_state

@onready var _ws_client = $WebSocketClient
@onready var player=$AudioStreamPlayer2

var _is_capturing := false
var _session_id := "your_session_id"
var _encoder := Opus.new()
var micrecorder
var capturer:AudioEffectCapture
var audio_input_rate:=AudioServer.get_input_mix_rate()
var audio_out_rate:=AudioServer.get_input_mix_rate()

var android_record
func _ready():
	# 初始化音频系统
	
	_encoder.update_mix_rate(audio_input_rate,audio_out_rate)
	var idx = AudioServer.get_bus_index("Record")
	print(AudioServer.get_input_mix_rate(),"输入帧率")
	#_audio_effect = AudioServer.get_bus_effect(idx, 0)
	capturer = AudioServer.get_bus_effect(idx, 0)
	micrecorder = AudioServer.get_bus_effect_instance(idx, 1)
			

	_ws_client.connection_established.connect(_on_connected)
	_ws_client.connection_closed.connect(_on_closed)
	_ws_client.data_received.connect(_on_data)
	_ws_client.connect_to_url(SERVER_URL)

func _process(_delta):

	
	
	_ws_client.poll()
	if _is_capturing:
		_process_audio()
		
func is_valued(number):
	return number != null
	


# 核心音频处理逻辑
func _process_audio():
	#var available_frames = _audio_effect.get_frames_available()
	#if not micrecorder.is_recording_active():
		#
	var target_frames = int((audio_input_rate * AUDIO_FRAME_MS) / 1000.0)
	var available_frames
	available_frames=capturer.get_frames_available()

	


	if available_frames<= 0:
		print("audio too short")
		return
	
	# 计算所需帧数：采样率16000 * 20ms = 320采样点/帧
	
	while available_frames >= target_frames:
		#var pcm_data = _audio_effect.get_buffer(available_frames)
		var data=capturer.get_buffer(target_frames)
		#data=resample_audio(data)
		#print(data.slice(0,20))
		var opus_frame = _encoder.encode(data)
		#print(opus_frame)
		
		# 发送二进制音频帧
		#var packet = _build_audio_packet(opus_frame)
		_ws_client.send(opus_frame)
		
		available_frames -= target_frames



# WebSocket 事件处理
func _on_connected(socket,protocol):
	print("Connected to server")
	send_handshake()

func _on_closed(reson):
	_is_capturing = false
	print("Connection closed")
	$Timer_for_web.start(5)

func _on_data(socket, message, is_string):
	#print(is_string)
	if is_string:
		#print(message.get_string_from_utf8())
		var msg=JSON.parse_string(message.get_string_from_utf8())
		print("收到信息",msg)

		_handle_server_message(msg)
	else:
		#print("获取到声音信号")
		var playback = player.get_stream_playback()
		_encoder.decode_and_play(playback,message)
# 关键控制命令
func send_handshake():
	var msg = {
		"type": "hello",
		"version": 2,
		"session_id": _session_id,
		"audio_params": {
			"format": "opus",
			"sample_rate": 16000,
			"channels": 1,
			"frame_ms": AUDIO_FRAME_MS
		}
	}
	_send_json(msg)

func start_capture():
	capturer.clear_buffer()
	_is_capturing = true
	_send_json({
		"type": "listen",
		"session_id": _session_id,
		"state": "start",
		"mode": "auto"
	})
	is_talking.emit(_is_capturing)

func stop_capture():
	_is_capturing = false

	is_talking.emit(_is_capturing)
	$Timer_for_conversation.start(30)
func stop_conversation():
	_send_json({
		"type": "listen",
		"session_id": _session_id,
		"state": "stop"
	})
func _send_json(data: Dictionary):
	var str = JSON.stringify(data)
	_ws_client.get_peer().put_packet(str.to_utf8_buffer())

func _handle_server_message(msg):
	#print(msg)
	match msg.get("type"):
		"hello":
			print("服务器已经建立链接")
		"llm":
			emotion_state.emit(msg.get("emotion"))	#start_capture()
		"audio_ack":
			print("Server received", msg.sequence)
		"error":
			push_error("Server error: ", msg.reason)


func _on_timer_for_web_timeout() -> void:
	_ws_client.connect_to_url(SERVER_URL)
	 # Replace with function body.


func _on_mic_finished() -> void:
	print("意外中止，重新播放")
	$Mic.playing=true
	pass # Replace with function body.
