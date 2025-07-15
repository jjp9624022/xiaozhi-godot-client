extends Node
var _encoder := Opus.new()
var capturer:AudioEffectCapture
var audio_input_rate:=AudioServer.get_input_mix_rate()
var audio_out_rate:=AudioServer.get_mix_rate()
var AUDIO_FRAME_MS=60
func _ready() -> void:
	var idx = AudioServer.get_bus_index("Record")
	print(AudioServer.get_input_mix_rate(),"输入帧率")
	#_audio_effect = AudioServer.get_bus_effect(idx, 0)
	capturer = AudioServer.get_bus_effect(idx, 1)
	_encoder.update_mix_rate(audio_input_rate,audio_out_rate)
	pass
func _process(delta: float) -> void:
	var target_frames = int((audio_input_rate * AUDIO_FRAME_MS) / 1000.0)
	if capturer.get_frames_available()<=target_frames:
		return
	var or_code=capturer.get_buffer(target_frames) 
	for i in range(or_code.size()):
		or_code[i]*=2
	var code=_encoder.encode(or_code)
	or_code.sort()
	#print(or_code.slice(0,40))
	#var playback = $out.get_stream_playback()
	print("原始数据",or_code.slice(0,40))
	var de_code=_encoder.decode(code)
	print("编码数据",code)
	de_code.sort()
	print("解码数据",de_code.slice(0,40))
	#_encoder.decode_and_play(playback,code)
	pass
