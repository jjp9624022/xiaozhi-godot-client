class_name PoseActor
extends Area3D
@onready var color=$MeshInstance3D['surface_material_override/0']
signal draging
func _ready() -> void:
	mouse_entered.connect(_on_area_3d_mouse_entered)
	mouse_exited.connect(_on_area_3d_mouse_exited)
	input_event.connect(_on_area_3d_input_event)

func _on_area_3d_mouse_entered() -> void:
	var color_tween=create_tween()
	color_tween.set_trans(Tween.TRANS_SINE)
	#var color=pose_area.color
	#var color=mesh_instance_3d['surface_material_override/0']
	color_tween.tween_property(color,"albedo_color:a",0.3,1)

func _on_area_3d_mouse_exited() -> void:
	var color_tween=create_tween()
	#var color=pose_area.color
	#var color=mesh_instance_3d['surface_material_override/0']
	color_tween.tween_property(color,"albedo_color:a",0,1)
	pass # Replace with function body.
func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("drag"):
		
		draging.emit()
		#active=true
		#act.emit()
	#elif event.is_action_released("drag"):	
		#draging.emit(false)	
