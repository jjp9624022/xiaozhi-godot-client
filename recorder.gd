extends Node
var effect:AudioEffectRecord
var capture:AudioEffectCapture
@export var web_servier_path : NodePath


@onready var web_servier=get_node(web_servier_path)
@export var frames_total=10
@export var record_vol=100
@onready var url="http://192.168.0.2:1880/audio"
@onready var time=$Timer
@export var threshold=0.5
@onready var recording:AudioStream
@onready var player=$AudioStreamPlayer2
var is_voice_detected: bool = false
signal is_listening

func _ready():
	print(web_servier_path)
	# We get the index of the "Record" bus.
	var idx = AudioServer.get_bus_index("record")
	# And use it to retrieve its first effect, which has been defined
	# as an "AudioEffectRecord" resource.
	effect = AudioServer.get_bus_effect(idx, 1)
	capture = AudioServer.get_bus_effect(idx, 0)
	#web_servier.data_received.connect(_on_data,0)
#func _on_data():
	#print(web_servier.get_peer().get_packet())	
	 
func _process(delta):
	#print(capture.get_buffer(frames_total))
	is_speeking(capture.get_buffer(frames_total))
	capture.clear_buffer()
	

func is_speeking(buffer:PackedVector2Array):
		# 计算能量
	var energy = 0.0
	for i in range(buffer.size()):
		energy += buffer[i].x * buffer[i].x
	 
		#print("能量：",buffer[i])

	energy /= buffer.size()
	

	# 检测人声
	if energy > threshold:
		print ("音量",energy)
		is_voice_detected = true
		if $TimerMax.time_left==0:
			$TimerMax.start()
		#print("someone speeking")
		start_record()
		#time.autostart=true
		time.start(2)
		#time.one_shot=true
		print("Voice detected!")
	else:
		is_voice_detected = false

func start_record():
	if effect.is_recording_active():
		pass
		#recording = effect.get_recording()

		#effect.set_recording_active(false)

	else:

		effect.set_recording_active(true)
		is_listening.emit()
		$Timer_eye_focus.start(30)
		
func stop_record():
	print("录音结束")
	effect.set_recording_active(false)
	#player.stream = recording
	#player.play()
	recording = effect.get_recording()
	#recording.set_mix_rate(11025)
	#recording.set_format(1)
	#recording.set_stereo(false)

	var data=recording.get_data()
	print(data.size())
	
		
	
	print("正在上传")
	#web_servier.send_text("准备上传")
	#print (web_servier.outbound_buffer_size) 
	#web_servier.outbound_buffer_size=data.size()+100
	#web_servier.get_peer().put_packet(data)
	#web_servier.set_buffers(64,64,64000)
	var data_base64=Marshalls.raw_to_base64(data)
	var json=JSON.stringify({"type":"audio","contents":data_base64})
	var headers= ["Content-Type: application/json"]
	web_servier.request(url, headers, HTTPClient.METHOD_POST, json)
	#web_servier.send(data,1)
	#save_wave()
	#player.
	$TimerMax.stop()

		
func save_wave():
	var save_path = "user://record.wav"
	recording.save_to_wav(save_path)	
	

func _on_timer_timeout():
	stop_record()

	 # Replace with function body.



	#print(message)
	#pass # Replace with function body.



	 # Replace with function body.


func _on_timer_max_timeout() -> void:
	if not time.is_stopped():
		print("录音超时")
		stop_record()
		
	 # Replace with function body.
