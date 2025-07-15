extends Node
var capture:AudioEffectCapture


@export var frames_total=100
@export var record_vol=100
@export var threshold=0.5
var is_voice_detected: bool = false
signal is_talking

func _ready():
	# We get the index of the "Record" bus.
	var idx = AudioServer.get_bus_index("Record")
	capture = AudioServer.get_bus_effect(idx, 1)
 
func _process(delta):
	is_speeking(capture.get_buffer(frames_total))
func calculate_rms(buffer):
	var sum = 0.0
	for s in buffer:
		sum += s.x * s.x
	return sqrt(sum / buffer.size())	

func is_speeking(buffer:PackedVector2Array):
		# 计算能量
	var energy =calculate_rms(buffer)

	#energy *=100
	#print ("音量",energy)
	# 检测人声
	if energy > threshold:
		print ("检测到说话")
		#print ("音量",energy)
		is_voice_detected = true
		
		$vad_detect_time.start(5)
		is_talking.emit(is_voice_detected)

func _on_vad_detect_time_timeout() -> void:
	is_voice_detected=false
	is_talking.emit(is_voice_detected)
	
	pass # Replace with function body.
