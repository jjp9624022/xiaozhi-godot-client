extends Node

const SERVER_URL = "ws://192.168.1.1:8000/xiaozhi/v1"
const AUDIO_FRAME_MS = 60  # 每帧音频时长（毫秒）
signal is_talking
signal emotion_state
@onready var _ws_client = $WebSocketClient
@onready var player=$AudioStreamPlayer2
@export var power=10
var _is_capturing := false
var _session_id := get_instance_id()
var _encoder := Opus.new()
var micrecorder
var capturer:AudioEffectCapture
var audio_input_rate:=AudioServer.get_input_mix_rate()
var audio_out_rate:=AudioServer.get_mix_rate()

var android_record
func _ready():
	# 初始化音频系统
	
	_encoder.update_mix_rate(audio_input_rate,audio_out_rate)
	var idx = AudioServer.get_bus_index("Record")
	print(AudioServer.get_input_mix_rate(),"输入帧率")
	#_audio_effect = AudioServer.get_bus_effect(idx, 0)
	capturer = AudioServer.get_bus_effect(idx, 1)
			

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

	var target_frames = int((audio_input_rate * AUDIO_FRAME_MS) / 1000.0)
	var available_frames
	available_frames=capturer.get_frames_available()

	if available_frames<= 0:
		print("audio too short")
		return		
	while available_frames >= target_frames:
		var data=capturer.get_buffer(target_frames)
		var opus_frame = _encoder.encode(data)
		print(opus_frame.size())
		_ws_client.send(opus_frame)		
		available_frames -= target_frames

func send_text(text):
	var msg = {
	"session_id": _session_id,
	"type": "listen",
	"state": "text_query",
	"text": text
}
	if text and _is_capturing:
		_send_json(msg)

# WebSocket 事件处理
func _on_connected(socket,protocol):
	print("Connected to server")
	send_handshake()

func _on_closed(reson):
	_is_capturing = false
	
	if $Timer_for_web.is_stopped():
		print("Connection closed,5秒重启")
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
		var code=_encoder.decode(message)
		_encoder.decode_and_play(playback,message)
		get_tree().call_group("is_talking", "_receive_data", "talking")
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
	if $Mic.playing==false:
		$Mic.playing=true
	capturer.clear_buffer()
	_is_capturing = true
	_send_json({
		"type": "listen",
		"session_id": _session_id,
		"state": "start",
		"mode": "auto"
	})
	get_tree().call_group("is_talking", "_receive_data", "listening")

func stop_capture():
	_is_capturing = false
	_send_json({
		"type": "listen",
		"session_id": _session_id,
		"state": "stop"
	})
	get_tree().call_group("is_talking", "_receive_data", "stop listen")
	

func _send_json(data: Dictionary):
	var str = JSON.stringify(data)
	_ws_client.get_peer().put_packet(str.to_utf8_buffer())

func _handle_server_message(msg):
	#print(msg)
	match msg.get("type"):
		"hello":
			print("服务器已经建立链接")
			_is_capturing = true
		"llm":
			emotion_state.emit(msg.get("emotion"))
			get_tree().call_group("tts", "_receive_data", msg.get("text"))	#start_capture()
		"audio_ack":
			print("Server received", msg.sequence)
		"error":
			push_error("Server error: ", msg.reason)
		"tts":
			if msg.state=="sentence_end":
				get_tree().call_group("tts", "_receive_data", msg.get("text"))


func _on_timer_for_web_timeout() -> void:
	_ws_client.connect_to_url(SERVER_URL)
	 # Replace with function body.


func _on_mic_finished() -> void:
	print("意外中止，重新播放")
	#$Mic.playing=true
	$Mic.playing=false
	var time=Timer.new()
	time.timeout.connect(fuckMic)
	add_child(time)
	time.start(2)
	pass # Replace with function body.
func fuckMic():
	print("mic重新启用")
	$Mic.playing=true
	$Mic.play()

func _on_vad_is_talking(state) -> void:
	if state and _is_capturing==false:
		start_capture()
	elif state==false and _is_capturing==true:
		stop_capture()
		pass
	
	pass # Replace with function body.
