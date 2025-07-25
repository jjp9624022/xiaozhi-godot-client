class_name HumanState
extends Resource
enum status {SPEEKING=2,LESTENING=1,IDLE=0,LESTEN_TEXT=3,TTS=4}
var tts:String
var text_to_send:String

@export var state:status
#@export_enum()
func _init():
	set_status(status.IDLE)

func set_status(stat):
#	避免重复调用
	if stat==state:return
	state=stat
	#print("设置状态",stat)
	emit_changed()
	
func get_status():
	return status
	
func set_tts(text:String):
	tts=text
	emit_changed()

func set_send_text(text:String):
	text_to_send=text
	emit_changed()
