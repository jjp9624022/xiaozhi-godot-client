extends Area3D
@onready var offset=Vector3.ZERO
var mouse_pos:Vector3
var dragged=false
signal act
func _ready() -> void:
	name="Head"
	input_ray_pickable=true	
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	mouse_pos=event_position#else:
	if event.is_action_pressed("drag"):
		dragged=true		
		act.emit()
		get_tree().call_group("draging", "_receive_data", dragged)
	if event.is_action_released("drag"):
		dragged=false
		get_tree().call_group("draging", "_receive_data", dragged)

func _physics_process(delta: float) -> void:
	if dragged:
		$Marker3D.position=to_local(mouse_pos)
		
	else:
		$Marker3D.position=Vector3.FORWARD
