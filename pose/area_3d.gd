extends Area3D
@onready var offset=Vector3.ZERO
var mouse_pos:Vector3
var dragged=false
func _ready() -> void:
	input_ray_pickable=true
	

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	mouse_pos=event_position#else:
	if event.is_action_pressed("drag"):
		dragged=true
		get_tree().call_group("draging", "_receive_data", dragged)
	if event.is_action_released("drag"):
		dragged=false
		get_tree().call_group("draging", "_receive_data", dragged)
		#var last_location=Vector3.FORWARD
		#offset=event_position-last_location
#
		#print("dragged")
	#else:
		#dragged=false
	#if dragged:
		#$Marker3D.position=Vector3.ZERO
	
	#print(event)
	pass # Replace with function body.
func _physics_process(delta: float) -> void:
	if dragged:
		$Marker3D.position=to_local(mouse_pos)
	else:
		#var tween = $Marker3D.create_tween()
		#tween.tween_property($Marker3D,"position",Vector3.FORWARD,0.3)
		$Marker3D.position=Vector3.FORWARD
