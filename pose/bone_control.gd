extends GodotIK
@export var camera_3d: Camera3D
@export var bone_id:int
@export var mesh_instance_3d: MeshInstance3D

func _ready() -> void:
	active=false
	#position=%GeneralSkeleton.get_bone_global_pose(82).origin
	#print(global_position)
func _physics_process(delta: float) -> void:
	if active:
		var mouse_pos = get_viewport().get_mouse_position()
		#var z=cam.
		# 计算鼠标在摄像机视口平面上的 3D 坐标
		var depth = 0.6  # 距离摄像机的深度（自定义值）
		var world_position:Vector3 = camera_3d.project_position(mouse_pos, depth)
		
		#print("3D Position: ", world_position)
		## 可选：在场景中显示位置（需创建 Marker3D 节点）
		#$Marker3D.position = world_position
		if world_position.distance_to(global_position)>0.05:
			var tween = get_tree().create_tween()
			#tween.tween_property(self,"global_position",world_position,0.1)
			global_position+=(world_position-global_position).normalized()*delta
	else:
			position=%GeneralSkeleton.get_bone_global_pose(bone_id).origin	

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("drag"):
		active=true
		get_tree().call_group("draging", "_receive_data", active)
		#print("draged")
	elif event.is_action_released("drag"):
		
		get_tree().call_group("draging", "_receive_data", active)
		var tween = get_tree().create_tween()
		var call=func():active=false
		tween.tween_property(self,"position",%GeneralSkeleton.get_bone_global_pose_no_override(bone_id).origin,0.3).finished.connect(call)
		#active=false


	
		#global_position=%GeneralSkeleton.get_bone_global_pose(82).origin
	pass # Replace with function body.


func _on_area_3d_mouse_entered() -> void:
	var color_tween=create_tween()
	color_tween.set_trans(Tween.TRANS_SINE)
	var color=mesh_instance_3d['surface_material_override/0']
	color_tween.tween_property(color,"albedo_color:a",0.3,1)
	#print($Area3D/MeshInstance3D['surface_material_override/0'].albedo_color)
	#$Area3D/MeshInstance3D['surface_material_override/0'].albedo_color.a=0.3
	pass # Replace with function body.


func _on_area_3d_mouse_exited() -> void:
	var color_tween=create_tween()
	var color=mesh_instance_3d['surface_material_override/0']
	color_tween.tween_property(color,"albedo_color:a",0,1)
	pass # Replace with function body.
