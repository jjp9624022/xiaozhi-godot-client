extends Control
@onready var charactor=$"../test2"
@onready var text_editor=$BoxContainer/HBoxContainer/CodeEdit
func _on_send_text_button_pressed() :
	charactor.send_text(text_editor.text)
	pass # Replace with function body.


func _on_test_2_tts(msg) -> void:
	var text=msg.get("text")
	if text==null:
		return
	

	#tts_text.append_text(msg.get("text"))
	pass # Replace with function body.


func _on_speek_button_down() -> void:
	charactor.start_send_audio()
	pass # Replace with function body.


func _on_speek_button_up() -> void:
	charactor.stop_send_audio()
	pass # Replace with function body.
