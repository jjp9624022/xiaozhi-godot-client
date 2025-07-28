extends Node
class_name Animation_web
@export var skeleton_path : NodePath
@onready var skeleton:Skeleton3D = get_node(skeleton_path)
@export var animation_path : NodePath
@export var scale:float=1.109527
@onready var player:AnimationPlayer = get_node(animation_path)

@export var cube_path : NodePath

@onready var motion:Array=[]
var motion_index:int=0
func _ready():
	
	pass

	
		
func action_mannge(motion_in):
	motion=motion_in
	#var animation:Animation=create_animation_from_motion(skeleton, motion)
	#var animation_name="test"
	#var animationLib= player.get_animation_library("")
	#if animationLib.has_animation(animation_name):
#
		#var change_animation=animationLib.get_animation(animation_name)
		#change_animation.clear()
#
	#animationLib.add_animation(animation_name, animation)
#
	#print("动画列表",animationLib.get_animation_list())
##
#
	#player.play(animation_name)
	#

func _process(delta):
	if motion.size()>1:
		do_motion_per_frame(motion[motion_index])
		motion_index=motion_index+1
		if motion_index>=motion.size():
			
			motion_index=0
			motion=[]
		pass
	# 每帧递增帧数计数器

	

var t2m_kinematic_chain = [[0, 3, 6, 9, 12, 15], [2, 5, 8, 11], [1, 4, 7, 10], [14, 17, 19, 21], [13, 16, 18, 20]]
var SMPL_JOINT_NAMES = [
	'Hips', 'LeftUpperLeg1', 'RightUpperLeg1', 'spine', 'LeftLowerLeg1', 'RightLowerLeg1', 'Chest1', 'LeftFoot1',
#	  0              1             2            3           4              5               6           7
	'RightFoot1', 'UpperChest1', 'Left_Toes1', 'Right_Toes1', 'Neck1', 'LeftShoulder1', 'RightShoulder1',
#	    8             9          10             11          12        13            14
	'Head1', 'LeftUpperArm1', 'RightUpperArm1', 'LeftLowerArm1', 'RightLowerArm1', 'LeftHand1', 'RightHand1'
#	 15             16              17              18            19                20        21 
]
var SMPL_JOINT_NAMES_bak = [
	'Hips', 'LeftUpperLeg', 'RightUpperLeg', 'spine', 'LeftLowerLeg', 'RightLowerLeg', 'Chest', 'LeftFoot',
#	  0              1             2            3           4              5               6           7
	'RightFoot', 'UpperChest', 'Left_Toes', 'Right_Toes', 'Neck', 'LeftShoulder', 'RightShoulder',
#	    8             9          10             11          12        13            14
	'Head', 'LeftUpperArm', 'RightUpperArm', 'LeftLowerArm', 'RightLowerArm', 'LeftHand', 'RightHand'
#	 15             16              17              18            19                20        21 
]

func to_godot_vector(smpl_xyz: Vector3) -> Vector3:
	return Vector3(-smpl_xyz.x, smpl_xyz.y, smpl_xyz.z)
	
func do_motion_per_frame(frame: Array):

	
	# 遍历每一帧，为每个骨骼插入关键帧
	#print("原始数据",frame)

	for bone_index_chain in t2m_kinematic_chain:
		
		var parent_tail_location
		if bone_index_chain[0] != 0:
			parent_tail_location = skeleton.get_bone_global_pose(skeleton.find_bone(SMPL_JOINT_NAMES[bone_index_chain[0]])).origin
		
		for chain_index in range(len(bone_index_chain) - 1):
			var bone_index = bone_index_chain[chain_index]			
			var joint_position_data = frame[bone_index].slice(0, 3)
			var joint_position = Vector3(joint_position_data[0],joint_position_data[1],joint_position_data[2]) / scale
			var head_joint_location = to_godot_vector(joint_position)
			
			var head_location = head_joint_location
			if parent_tail_location == null:
				head_location = parent_tail_location
						
			var tail_joint_index = bone_index_chain[chain_index + 1]
			var tail_joint_position_data = frame[tail_joint_index].slice(0, 3)
			var tail_joint_position = Vector3(tail_joint_position_data[0],tail_joint_position_data[1],tail_joint_position_data[2]) / scale
			var tail_joint_location = to_godot_vector(tail_joint_position)
			
			# Calculate direction and up vector for rotation
			var direction = (tail_joint_location - head_location).normalized()
			var up_direction = Vector3(0, 1, 0)
			var quaternion = Quaternion(up_direction,direction)
			var basis = Basis().looking_at(direction, up_direction)
			# Calculate the new tail location based on the bone length and rotation
			var bone_length = (tail_joint_location - head_location).length()
			parent_tail_location = head_location + quaternion * Vector3(0,bone_length, 0)
			
			# Create Transform3D from Basis and location
			var global_transform = Transform3D(basis, head_location)
			
			# Convert global transform to local transform
#				获取真实骨骼的索引
			var skeleton_bone_index=skeleton.find_bone(SMPL_JOINT_NAMES[bone_index])
#				设置参考cube的动画

			var parent_global_transform = skeleton.get_bone_global_pose(skeleton_bone_index)

			var parent_inverse_transform = parent_global_transform.affine_inverse()
			var local_transform = parent_inverse_transform * global_transform
			skeleton.set_bone_pose_rotation(skeleton_bone_index, local_transform.basis.get_rotation_quaternion())
			skeleton.set_bone_pose_position(skeleton_bone_index, local_transform.origin)

			#skeleton.force_update_bone_child_transform(skeleton_bone_index)
			# 确保骨骼索引与轨道索引对应


func create_animation_from_motion(skeleton: Skeleton3D, motion: Array):
	var animation:Animation = Animation.new()
	var timestep = 0.033333
	#skeleton.reset_bone_poses()
	animation.length = 196 * timestep
	
	# 遍历每一帧，为每个骨骼插入关键帧
	for frame in range(motion.size()):
		for bone_index_chain in t2m_kinematic_chain:
			
			var parent_tail_location
			#print("判断",parent_tail_location==null)
			if bone_index_chain[0] != 0:
				parent_tail_location = skeleton.get_bone_global_pose(bone_index_chain[0]).origin
			
			for chain_index in range(len(bone_index_chain) - 1):
				var bone_index = bone_index_chain[chain_index]

				
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
				var up_direction = Vector3(0, 1, 0)
				var quaternion = Quaternion(up_direction,direction)
				var basis = Basis().looking_at(direction, up_direction)
				# Calculate the new tail location based on the bone length and rotation
				var bone_length = (tail_joint_location - head_location).length()
				parent_tail_location = head_location + quaternion * Vector3(0,bone_length, 0)
				
				# Create Transform3D from Basis and location
				var global_transform = Transform3D(basis, head_location)
				
				# Convert global transform to local transform
				#var local_transform = skeleton.global_transform_to_local(global_transform)
#				获取真实骨骼的索引
				var skeleton_bone_index=skeleton.find_bone(SMPL_JOINT_NAMES[bone_index])
#				设置参考cube的动画

				var parent_global_transform = skeleton.get_bone_global_pose(skeleton_bone_index)
				var parent_inverse_transform = parent_global_transform.affine_inverse()
				var local_transform = parent_inverse_transform * global_transform
				#print(skeleton.get_bone_name(skeleton_bone_index))
				#skeleton.set_bone_pose_rotation(skeleton_bone_index, local_transform.basis.get_rotation_quaternion())
				#skeleton.set_bone_pose_position(skeleton_bone_index, local_transform.origin)
				skeleton.set_bone_global_pose_override(skeleton_bone_index, local_transform, 1.0, true)

				#skeleton.force_update_bone_child_transform(skeleton_bone_index)
				# 确保骨骼索引与轨道索引对应
				var track_index = animation.find_track(NodePath(skeleton.name+":"+skeleton.get_bone_name(skeleton_bone_index)),Animation.TYPE_ROTATION_3D)
				if track_index == -1:
					# 如果没有找到对应的轨道，创建新的轨道
					track_index = animation.add_track(Animation.TYPE_ROTATION_3D)
					animation.track_set_path(track_index, NodePath(skeleton.name+":"+skeleton.get_bone_name(skeleton_bone_index)))
					
				var position_track_index = animation.find_track(NodePath(skeleton.name+":"+skeleton.get_bone_name(skeleton_bone_index)),Animation.TYPE_POSITION_3D)
				if position_track_index == -1:
					# 如果没有找到对应的轨道，创建新的轨道
					position_track_index = animation.add_track(Animation.TYPE_POSITION_3D)
					animation.track_set_path(position_track_index, NodePath(skeleton.name+":"+skeleton.get_bone_name(skeleton_bone_index)))
				if SMPL_JOINT_NAMES[bone_index]=="Hips":
					set_anmation(animation,frame*timestep,local_transform.origin)
				# 插入关键帧
				animation.rotation_track_insert_key(track_index, frame*timestep, skeleton.get_bone_pose_rotation(position_track_index))
				animation.position_track_insert_key(position_track_index, frame*timestep, skeleton.get_bone_pose_position(position_track_index))
	
	# 播放动画
	return animation
func set_anmation(animation:Animation,frame,pos):
	var track_index = animation.find_track(NodePath("cube"),Animation.TYPE_POSITION_3D)
	if track_index == -1:
					# 如果没有找到对应的轨道，创建新的轨道
		track_index = animation.add_track(Animation.TYPE_POSITION_3D)
		animation.track_set_path(track_index, NodePath("cube"))
				
				# 插入关键帧
	animation.position_track_insert_key(track_index, frame, pos)
	pass
