class_name HeadArea
extends Area3D
@onready var offset=Vector3.ZERO
@onready var look_at_modifier_3d: LookAtModifier3D = $"../../LookAtModifier3D"
@export var human_status:HumanState

var mouse_pos:Vector3
var dragged=false
signal act
func _ready() -> void:
	name="Head"
	input_ray_pickable=true	
	#look_at_modifier_3d.modification_processed.connect(_on_moved)
	human_status.changed.connect(_on_moved.bind(human_status))
	
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	mouse_pos=event_position#else:
	if event.is_action_pressed("drag"):
		#look_at_modifier_3d.influence=0.7
		look_at_modifier_3d.active=true
		dragged=true		
		act.emit()

		get_tree().call_group("draging", "_receive_data", dragged)
	if event.is_action_released("drag"):
		$Marker3D.position=Vector3.FORWARD
		#look_at_modifier_3d.influence=0.1
		dragged=false
		get_tree().call_group("draging", "_receive_data", dragged)
		
func _on_moved(human_status:HumanState):
	if human_status.state==HumanState.status.LESTENING:
		look_at_modifier_3d.active==false
	#if not dragged:
		#look_at_modifier_3d.active=false
	pass
func _physics_process(delta: float) -> void:
	if dragged:
		$Marker3D.position=to_local(mouse_pos)
		#
	#else:
		
