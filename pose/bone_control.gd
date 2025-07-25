class_name VrmIK
extends GodotIK
@export var camera_3d: Camera3D
@export var bone_id:int
@export var pose_area: PoseActor
signal act
func _ready() -> void:
	active=false
	
	pose_area.input_event.connect(_on_area_3d_input_event)
	#pose_area.mouse_entered.connect(_on_area_3d_mouse_entered)
	#pose_area.mouse_exited.connect(_on_area_3d_mouse_exited)
	

func _physics_process(delta: float) -> void:
	if active:
		var mouse_pos = get_viewport().get_mouse_position()
		var depth = 0.6  # 距离摄像机的深度（自定义值）
		var world_position:Vector3 = camera_3d.project_position(mouse_pos, depth)
		if world_position.distance_to(global_position)>0.05:
			global_position+=(world_position-global_position).normalized()*delta
	else:
			position=%GeneralSkeleton.get_bone_global_pose(bone_id).origin	

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("drag"):
		active=true
		act.emit()
		get_tree().call_group("draging", "_receive_data", active)
	elif event.is_action_released("drag"):		
		get_tree().call_group("draging", "_receive_data", active)
		var	tween = get_tree().create_tween()	
		var call=func():active=false
		tween.tween_property(self,"position",%GeneralSkeleton.get_bone_global_pose_no_override(bone_id).origin,0.3).finished.connect(call)
