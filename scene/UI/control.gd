extends Control
@onready var code_edit: CodeEdit = $BoxContainer/HBoxContainer/CodeEdit
var settings_ui
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
	pass # Replace with function body.


func _on_speek_button_down() -> void:
	human_status.set_status(HumanState.status.LESTENING)
	pass # Replace with function body.

func _on_speek_button_up() -> void:
	human_status.set_status(HumanState.status.IDLE)
	pass # Replace with function body.


func _on_setting_button_pressed() -> void:
	if not settings_ui:
		settings_ui = preload("res://scene/UI/SettingUI.tscn").instantiate()
		add_child(settings_ui)
	else :
		remove_child(settings_ui)
		settings_ui=null
	#get_node() # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
