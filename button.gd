extends Button

@onready var text_edit=$"../CodeEdit"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _pressed() -> void:
	text_edit.text
	
