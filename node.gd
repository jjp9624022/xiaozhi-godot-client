extends Node
@export var skeleton_path : NodePath
@onready var skeleton:Skeleton3D = get_node(skeleton_path)
@export var animation_path : NodePath
@export var scale:float=1.109527
@onready var player:AnimationPlayer = get_node(animation_path)

@export var cube_path : NodePath

var edges = [
		Vector2(18, 20), Vector2(16, 18), Vector2(13, 16), Vector2(12, 15),Vector2(14, 17), Vector2(17, 19), Vector2(19, 21), 
		Vector2(9, 6),Vector2(3, 6),
		Vector2(3, 0), 
		Vector3(0, 1,2), Vector3(9, 14,13),
		Vector2(1, 4), Vector2(2, 5), Vector2(4, 7), Vector2(7, 10),Vector2(5, 8), Vector2(8, 11),
	]
var bone_names_map = [
		"LeftLowerArm", "LeftUpperArm", "LeftShoulder", "Neck", "RightShoulder", "RightUpperArm","RightLowerArm", 
		"UpperChest", "Chest", 
		"Hips",
		"LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "LeftFoot", "RightLowerLeg", "RightFoot",
	]
var t2m_kinematic_chain = [[0, 3, 6, 9, 12, 15], [2, 5, 8, 11], [1, 4, 7, 10], [14, 17, 19, 21], [13, 16, 18, 20]]
var SMPL_JOINT_NAMES = [
	'Hips', 'LeftUpperLeg', 'RightUpperLeg', 'spine', 'LeftLowerLeg', 'RightLowerLeg', 'Chest', 'LeftFoot',
#	  0              1             2            3           4              5               6           7
	'RightFoot', 'UpperChest', 'Left_Toes', 'Right_Toes', 'Neck', 'LeftShoulder', 'RightShoulder',
#	    8             9          10             11          12        13            14
	'Head', 'LeftUpperArm', 'RightUpperArm', 'LeftLowerArm', 'RightLowerArm', 'LeftHand', 'RightHand'
#	 15             16              17              18            19                20        21 
]
var SMPL_JOINT_NAMES_BACK = [
	'pelvis', 'left_hip', 'right_hip', 'spine1', 'left_knee', 'right_knee', 'spine2', 'left_ankle',
	'right_ankle', 'spine3', 'left_foot', 'right_foot', 'neck', 'left_collar', 'right_collar',
	'head', 'left_shoulder', 'right_shoulder', 'LeftLowerArm', 'RightLowerArm', 'Left_Hand', 'Right_Hand'
]
var bone_edges_dict = {
	"LeftLowerArm": {"edge": [16,18, 20], "rotation": Vector3(1, 0, 0)},
	"RightLowerArm": {"edge": [17,19, 21], "rotation": Vector3(1, 0, 0)},
	"LeftUpperArm": {"edge": [13,16, 18], "rotation": Vector3(1, 0, 0)},
	"RightUpperArm": {"edge": [14,17, 19], "rotation": Vector3(1, 0, 0)},
	"LeftShoulder": {"edge": [9,13, 16], "rotation": Vector3(-1, 0, 0)},
	"RightShoulder": {"edge": [9,14, 17], "rotation": Vector3(-1, 0, 0)},
	"Neck": {"edge": [9,12, 15], "rotation": Vector3(1, 0, 0)},
	"UpperChest": {"edge": [3,6, 9], "rotation": Vector3(1, 0, 0)},
	"Chest": {"edge": [0,3, 6], "rotation": Vector3(1, 0, 0)},
	"Hips": {"edge": [0,1, 2], "rotation": Vector3(0, 1, 0)},  # 使用数组
	"Hip_towords": {"edge": [0, 1, 2], "rotation": Vector3(0, 1, 0)},
	"LeftUpperLeg": {"edge": [0,1, 4], "rotation": Vector3(1, 0, 0)},
	"RightUpperLeg": {"edge": [0,2, 5], "rotation": Vector3(1, 0, 0)},
	"LeftLowerLeg": {"edge": [1,4, 7], "rotation": Vector3(1, 0, 0)},
	"LeftFoot": {"edge": [4,7, 10], "rotation": Vector3(1, 0, 0)},
	"RightLowerLeg": {"edge": [2,5, 8], "rotation": Vector3(1, 0, 0)},
	"RightFoot": {"edge": [5,8, 11], "rotation": Vector3(1, 0, 0)}
	}

func to_godot_vector(smpl_xyz: Vector3) -> Vector3:
	return Vector3(smpl_xyz.x, smpl_xyz.y, smpl_xyz.z)
	


func create_animation_from_motion(skeleton: Skeleton3D, motion: Array):
	var animation:Animation = Animation.new()
	var timestep = 0.033333
	#skeleton.reset_bone_poses()
	animation.length = 196 * timestep
	
	# 遍历每一帧，为每个骨骼插入关键帧
	for frame in range(motion.size()):
		for bone_index_chain in t2m_kinematic_chain:
			var parent_tail_location: Vector3
			if bone_index_chain[0] != 0:
				parent_tail_location = skeleton.get_bone_global_pose(bone_index_chain[0]).origin

			for chain_index in range(len(bone_index_chain) - 1):
				var bone_index = bone_index_chain[chain_index]
				
				# Extract the first three elements as position data using subarray
				var joint_position_data = motion[frame][bone_index].slice(0, 3)
				#print("位置坐标",joint_position_data)
				var joint_position = Vector3(joint_position_data[0],joint_position_data[1],joint_position_data[2]) / scale
				var head_joint_location = to_godot_vector(joint_position)
				
				var head_location = head_joint_location
				if parent_tail_location != null:
					head_location = parent_tail_location
				
				var tail_joint_index = bone_index_chain[chain_index + 1]
				var tail_joint_position_data = motion[frame][tail_joint_index].slice(0, 3)
				var tail_joint_position = Vector3(tail_joint_position_data[0],tail_joint_position_data[1],tail_joint_position_data[2]) / scale
				var tail_joint_location = to_godot_vector(tail_joint_position)
				
				# Calculate direction and up vector for rotation
				var direction = (tail_joint_location - head_location).normalized()
				var up_direction = Vector3(0, 0, 1)
				var quaternion = Quaternion(up_direction,direction)
				var basis = Basis().looking_at(direction, up_direction)
				# Calculate the new tail location based on the bone length and rotation
				var bone_length = (tail_joint_location - head_location).length()
				parent_tail_location = head_location + quaternion * Vector3(0,bone_length, 0)
				
				# Create Transform3D from Basis and location
				var global_transform = Transform3D(basis, head_location)
				
				# Convert global transform to local transform
				#var local_transform = skeleton.global_transform_to_local(global_transform)
				var parent_global_transform = skeleton.get_bone_global_pose(bone_index)
				var parent_inverse_transform = parent_global_transform.affine_inverse()
				var local_transform = parent_inverse_transform * global_transform
				
				# 确保骨骼索引与轨道索引对应
				var track_index = animation.find_track(NodePath(skeleton.name+":"+skeleton.get_bone_name(bone_index)),Animation.TYPE_ROTATION_3D)
				if track_index == -1:
					# 如果没有找到对应的轨道，创建新的轨道
					track_index = animation.add_track(Animation.TYPE_ROTATION_3D)
					animation.track_set_path(track_index, NodePath(skeleton.name+":"+skeleton.get_bone_name(bone_index)))
				
				# 插入关键帧
				animation.rotation_track_insert_key(track_index, frame*timestep, local_transform.basis.get_rotation_quaternion())
	
	# 播放动画
	return animation
	
	
func parse_motion_v1(bone_edges_dict:Dictionary, bone_index_map:Array, motion_array:Array) -> Animation:

	
	var animation:Animation = Animation.new()
	var timestep = 0.033333
	#skeleton.reset_bone_poses()
	animation.length = 196 * timestep
			
	
	for i in range(len(bone_index_map)):
		var rotation_track = animation.add_track(Animation.TYPE_ROTATION_3D)
		var position_track = animation.add_track(Animation.TYPE_POSITION_3D)
		
		# var motions=motion_array[i]
		# skeleton.localize_rests()
		var bone_name=bone_index_map[i]
		var bone_inx=skeleton.find_bone(bone_name)
		if not bone_inx:
			print("未找到骨骼",bone_name)
			break
		for m in range(len(motion_array[0][0])):

			#m=0#先不循环
			#每次都要计算系统的旋转方向
			
			var up_joint_index=bone_edges_dict[bone_name].edge[0]
			var cur_joint_index=bone_edges_dict[bone_name].edge[1]
			var down_joint_index=bone_edges_dict[bone_name].edge[2]
			var rot_axis:Vector3=bone_edges_dict[bone_name].rotation
			
			#var motion_array[up_joint][0][m]
			var get_vector=func(index):
				return Vector3(motion_array[index][0][m],motion_array[index][1][m],motion_array[index][2][m])
				
			var up_joint_p:Vector3=get_vector.call(up_joint_index)
			var cur_joint_p:Vector3=get_vector.call(cur_joint_index)
			var down_joint_p:Vector3=get_vector.call(down_joint_index)
			var root_rot
			var root_angle	
			
			
			var get_root_rot=func():


				var root_up_joint_p:Vector3=get_vector.call(0)
				var root_cur_joint_p:Vector3=get_vector.call(1)
				var root_down_joint_p:Vector3=get_vector.call(2)
				
				var up_vector=up_joint_p.direction_to(cur_joint_p)
				var down_vector=up_joint_p.direction_to(down_joint_p)
				var normal=up_vector.cross(down_vector).normalized()
				#print(Vector3(0,0,1).dot(normal),"方向")
				var base=skeleton.get_global_transform()
				var angle=Vector3(0,0,-1).angle_to(normal)
				var rot=base.rotated(Vector3(0,1,0),angle).basis.get_rotation_quaternion()
				#var rot2=base.rotated(Vector3(0,1,0),angle).basis.get_rotation_quaternion()
				var rot2=Quaternion(Vector3(0,0,-1),normal).normalized().get_euler()
				rot2.z=0
				#var rot2=base.looking_at(root_cur_joint_p,Vector3(0,1,0)).basis.get_rotation_quaternion()
				return [angle,Quaternion.from_euler(rot2)]

		#"UpperChest", "Chest", 
			#"Hips",
			#"Hip_towords", "shoulder_towords",
			#"LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "LeftFoot", "RightLowerLeg", "RightFoot",
			var get_rot_from_three_point=func (add_angle=0,ax=Vector3(1,0,0)):
#				单轴旋转
				var up_vector=up_joint_p.direction_to(cur_joint_p)
				var down_vector=cur_joint_p.direction_to(down_joint_p)
				var angle= up_vector.angle_to(down_vector)
				#print(bone_name,"角度",rad_to_deg(angle))
				#print(bone_name,"原始四元变换",skeleton.get_bone_pose_rotation(bone_inx).get_angle())
				var bone_rot=skeleton.get_bone_rest(bone_inx)
				#var bone_rot=skeleton.get_bone_pose(bone_inx)
				var trans:Transform3D=bone_rot.rotated_local(ax,add_angle).rotated_local(rot_axis,angle)
				var q2=trans.basis.get_rotation_quaternion()
				
				return q2
				
			match bone_name:
				"LeftLowerArm","RightLowerArm", "LeftLowerLeg", "RightLowerLeg","LeftUpperLeg", "RightUpperLeg",\
				  "UpperChest":

					var q2=get_rot_from_three_point.call()
					
					animation.rotation_track_insert_key(rotation_track, m*timestep, q2)
				"Chest":
					var q2=get_rot_from_three_point.call(deg_to_rad(0))
					
					animation.rotation_track_insert_key(rotation_track, m*timestep, q2)
				"Neck":
					var q2=get_rot_from_three_point.call(deg_to_rad(-10))
					
					animation.rotation_track_insert_key(rotation_track, m*timestep, q2)
				"LeftFoot","RightFoot":
					var q2=get_rot_from_three_point.call(deg_to_rad(-90))
					
					animation.rotation_track_insert_key(rotation_track, m*timestep, q2)
						
				"Hip_towords","Hips":

					var q=get_root_rot.call()[1]
					
					animation.position_track_insert_key(position_track,m*timestep,up_joint_p*scale)
					animation.rotation_track_insert_key(rotation_track, m*timestep, q)
					
				"RightShoulder":
					var up_vector=up_joint_p.direction_to(cur_joint_p)
					var down_vector=cur_joint_p.direction_to(down_joint_p)
					#var angle= up_vector.angle_to(down_vector)

					var rotated_up_vector =up_vector.rotated(Vector3(0, 0, -1),get_root_rot.call()[0])
					var rotated_down_vector = down_vector.rotated(Vector3(0, 0, -1),get_root_rot.call()[0])
					#var ts=skeleton.get_global_transform().looking_at()
					#print(bone_name,"角度",rad_to_deg(angle))
					#print(bone_name,"原始四元变换",skeleton.get_bone_pose_rotation(bone_inx).get_angle())
					var bone_rot=skeleton.get_bone_rest(bone_inx)
					#print("基本旋转",rad_to_deg(root_angle[m]))
					var trans:Transform3D=bone_rot.rotated(Vector3(0,0,1),get_root_rot.call()[0]-deg_to_rad(35))#.rotated_local(Vector3(0,0,1),deg_to_rad(90))
					var q1=Quaternion(up_vector,down_vector)
					var q2=q1.inverse()*(trans.basis.get_rotation_quaternion())
					animation.rotation_track_insert_key(rotation_track, m*timestep, q2)
				"LeftShoulder":
					#var up_vector=up_joint_p.direction_to(cur_joint_p)
					#var down_vector=cur_joint_p.direction_to(down_joint_p)
					#var rot2=Quaternion(up_vector,down_vector).get_euler()
					#rot2.z=0
					#var bone_rot=skeleton.get_bone_rest(bone_inx).rotated_local(Vector3(0,1,0),deg_to_rad(-90)).basis.get_rotation_quaternion()
					#var q2=bone_rot.inverse()*Quaternion.from_euler(rot2)
					var up_vector=up_joint_p.direction_to(cur_joint_p)
					var down_vector=cur_joint_p.direction_to(down_joint_p)
					var bone_rot=skeleton.get_bone_rest(bone_inx)
					var trans:Transform3D=bone_rot.rotated(Vector3(0,0,1),get_root_rot.call()[0]-deg_to_rad(145))#.rotated_local(Vector3(0,1,0),deg_to_rad(40))
					var q1=Quaternion(up_vector,down_vector)
	
					var q2=q1.inverse()*(trans.basis.get_rotation_quaternion())					
					animation.rotation_track_insert_key(rotation_track, m*timestep, q2)					

					
					#skeleton.set_bone_pose_rotation(0,q2)
		animation.track_set_path(rotation_track,NodePath(skeleton.name+":"+skeleton.get_bone_name(bone_inx)))
		animation.track_set_path(position_track,NodePath(skeleton.name+":"+skeleton.get_bone_name(0)))
				


		
	return animation


func _on_animation_player_2_animation_finished(anim_name: StringName) -> void:
	#print("播放完成")
	#var tr:AnimationTree=get_node("../../AnimationPlayer/AnimationTree")
	#
	#tr["parameters/conditions/is_reset"]=true
	#player.play("web_motion")
	#skeleton.reset_bone_poses()
	pass # Replace with function body.





func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#if anim_name=="kiss2":
		#print("动画捕捉到了")
		#var tr:AnimationTree=get_node("../../AnimationPlayer/AnimationTree")
		#
		#tr["parameters/conditions/is_player_web"]=false
	pass # Replace with function body.
