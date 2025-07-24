extends Control
@onready var code_edit: CodeEdit = $BoxContainer/HBoxContainer/CodeEdit

@onready var text_editor=$BoxContainer/HBoxContainer/CodeEdit
@export var human_status:HumanState
func _on_send_text_button_pressed() :
	human_status.set_send_text(code_edit.text)
	human_status.set_status(HumanState.status.LESTEN_TEXT)
	code_edit.text=""
	pass # Replace with function body.


func _on_test_2_tts(msg) -> void:
	var text=msg.get("text")
	if text==null:
		return
	

	#tts_text.append_text(msg.get("text"))
	pass # Replace with function body.


func _on_speek_button_down() -> void:
	human_status.set_status(HumanState.status.LESTENING)
	pass # Replace with function body.

func _on_speek_button_up() -> void:
	human_status.set_status(HumanState.status.IDLE)
	pass # Replace with function body.

func _on_face_check_button_button_down() -> void:
	set_process(true)
	var loader = ResourceLoader.load_threaded_request("res://face_reg.tscn")
	pass # Replace with function body.

func _on_face_check_button_button_up() -> void:
	var face=get_node("face_reg")
	remove_child(face)
	set_process(false)
	pass # Replace with function body.
func _process(delta: float) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status("res://face_reg.tscn", progress)
	if status==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		print("加载中",progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get("res://face_reg.tscn")
		var instance = scene.instantiate()
		add_child(instance)
		set_process(false)
