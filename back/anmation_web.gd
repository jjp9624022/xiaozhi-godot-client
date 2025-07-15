@tool
extends Node
# 配置常量
# 配置常量


const SKELETON_PATH = "skeleton_path"
const IGNORE_OFFSETS = "ignore_offsets"
const TRANSFORM_SCALING = "transform_scaling"
const AXIS_ORDER = "force_axis_ordering"
const BONE_REMAPPING_JSON = "bone_remapping_json"
const RIGHT_VECTOR = "right_vector"
const UP_VECTOR = "up_vector"
const FORWARD_VECTOR = "forward_vector"

# 骨骼通道常量
const XPOS = "Xposition"
const YPOS = "Yposition"
const ZPOS = "Zposition"
const XROT = "Xrotation"
const YROT = "Yrotation"
const ZROT = "Zrotation"
var trans_ref={
	"Spine" :["XYZ" , [1, 1, 1]],
	"Chest" :["XYZ" , [1, 1, 1]],
	"UpperChest" :["XYZ" , [1, 1, 1]],
	"Neck" :["XYZ" , [1, 1, 1]],
	"Head" :["XYZ" , [1, 1, 1]],
	"LeftShoulder" :["YZX" , [1, 1, 1]],
	"LeftUpperArm" :["YZX" , [-1, 1, -1]],
	"LeftLowerArm" :["YXZ" , [1, 1, 1]],
	"LeftHand" :["YZX" , [-1, 1, -1]],
	"LeftThumbMetacarpal" :["YXZ" , [1, 1, -1]],
	"LeftUpperLeg" :["XYZ" , [-1, -1, 1]],
	"LeftLowerLeg" :["XYZ" , [-1, -1, -1]],
	"LeftFoot" :["ZYX" , [1, -1, -1]],
	"LeftToes" :["YZX" , [1, 1, 1]],
	"RightShoulder" :["XYZ" , [1, 1, 1]],
	"RightUpperArm" :["YZX" , [-1, -1, 1]],
	"RightLowerArm" :["XZY" , [-1, 1, -1]],
	"RightHand" :["YXZ" , [1, -1, 1]],
	"RightUpperLeg" :["XYZ" , [-1, -1, 1]],
	"RightLowerLeg" :["XYZ" , [1, -1, -1]],
	"RightFoot" :["YZX" , [1, -1, 1]],
	"RightToes" :["XZY" , [1, 1, -1]]
}
# 轴顺序枚举
enum AXIS_ORDERING {NATIVE=0, XYZ, XZY, YXZ, YZX, ZXY, ZYX, REVERSE }
var config = {
	"skeleton_path": "%GeneralSkeleton",    # 目标骨架节点路径
	"ignore_offsets": false,           # 是否忽略骨骼偏移
	"transform_scaling": 0.01,         # 缩放因子（BVH单位到Godot单位）
	"force_axis_ordering": AXIS_ORDERING.NATIVE,          # 旋转顺序（使用AXIS_ORDERING枚举）
	"bone_remapping_json": {           # 骨骼重映射字典
		  "Hips": "Hips",
  "LeftUpLeg": "LeftUpperLeg",
  "LeftLeg": "LeftLowerLeg",
  "LeftFoot": "LeftFoot",
  "LeftToeBase": "LeftToes",
  "RightUpLeg": "RightUpperLeg",
  "RightLeg": "RightLowerLeg",
  "RightFoot": "RightFoot",
  "RightToeBase": "RightToes",
  "Spine": "Spine",
  "Spine1": "Chest",
  "Spine2": "UpperChest",
  "Neck": "Neck",
  "Head": "Head",
  "LeftShoulder": "LeftShoulder",
  "LeftArm": "LeftUpperArm",
  "LeftForeArm": "LeftLowerArm",
  "LeftHand": "LeftHand",
  "LeftHandThumb1": "LeftThumbMetacarpal",
  "LeftHandThumb2": "LeftThumbProximal",
  "LeftHandThumb3": "LeftThumbDistal",
  "LeftHandIndex1": "LeftIndexProximal",
  "LeftHandIndex2": "LeftIndexIntermediate",
  "LeftHandIndex3": "LeftIndexDistal",
  "LeftHandMiddle1": "LeftMiddleProximal",
  "LeftHandMiddle2": "LeftMiddleIntermediate",
  "LeftHandMiddle3": "LeftMiddleDistal",
  "LeftHandRing1": "LeftRingProximal",
  "LeftHandRing2": "LeftRingIntermediate",
  "LeftHandRing3": "LeftRingDistal",
  "LeftHandPinky1": "LeftLittleProximal",
  "LeftHandPinky2": "LeftLittleIntermediate",
  "LeftHandPinky3": "LeftLittleDistal",
  "RightShoulder": "RightShoulder",
  "RightArm": "RightUpperArm",
  "RightForeArm": "RightLowerArm",
  "RightHand": "RightHand",
  "RightHandThumb1": "RightThumbMetacarpal",
  "RightHandThumb2": "RightThumbProximal",
  "RightHandThumb3": "RightThumbDistal",
  "RightHandIndex1": "RightIndexProximal",
  "RightHandIndex2": "RightIndexIntermediate",
  "RightHandIndex3": "RightIndexDistal",
  "RightHandMiddle1": "RightMiddleProximal",
  "RightHandMiddle2": "RightMiddleIntermediate",
  "RightHandMiddle3": "RightMiddleDistal",
  "RightHandRing1": "RightRingProximal",
  "RightHandRing2": "RightRingIntermediate",
  "RightHandRing3": "RightRingDistal",
  "RightHandPinky1": "RightLittleProximal",
  "RightHandPinky2": "RightLittleIntermediate",
  "RightHandPinky3": "RightLittleDistal"
	},
	"right_vector": Vector3.RIGHT,     # 右轴方向
	"up_vector": Vector3.UP,           # 上轴方向
	"forward_vector": Vector3.FORWARD  # 前轴方向
}


# 轴顺序枚举


func load_text_file(path: String) -> String:
	# 检查文件是否存在
	if not FileAccess.file_exists(path):
		push_error("文件不存在: " + path)
		return ""
	
	# 打开文件
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("打开文件失败: " + str(FileAccess.get_open_error()))
		return ""
	
	# 读取内容
	var content = file.get_as_text()
	file.close()  # 关闭文件
	return content
	
	
func get_hvb_web(link):
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_http_request_request_completed)
	var body:Dictionary={
  "text_prompt": "walking",
  "motion_length": 10,
  "repeat_times": 1,
  "cond_scale": 4,
  "temperature": 1,
  "topkr": 0.9,
  "gumbel_sample": false,
  "use_res_model": true,
  "generate_video": false,
  "generate_animation": false,
  "time_steps": 18
}

	var request =http.request(link, [], HTTPClient.METHOD_POST, JSON.stringify(body))


	if request != OK:
		push_error("Http request error")

func _ready() -> void:
	var hvb=load_text_file("res://animation/pray.bvh")
	var animation:Animation=create_animation_from_bvh(hvb,config)
	var animation_name="test"
	var player=$"../../AnimationPlayer2"
	var animationLib= player.get_animation_library("")
	if animationLib.has_animation(animation_name):
		var change_animation=animationLib.get_animation(animation_name)
		change_animation.clear()
	animationLib.add_animation(animation_name, animation)
	print("动画列表",animationLib.get_animation_list())
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		push_error("Download Failed retry")
	else:
		var bvh=body.get_string_from_ascii()

		create_animation_from_bvh(bvh,config)
		
# 主函数：从BVH字符串创建动画
func create_animation_from_bvh(bvh_text: String, config: Dictionary) -> Animation:
	var parsed_file = parse_bvh(bvh_text)
	var hierarchy_lines = parsed_file[0]
	var motion_lines = parsed_file[1]
	
	var hdata = parse_hierarchy(hierarchy_lines)
	var root_bone_name = hdata[0]
	var bone_names = hdata[1]
	var bone_index_map = hdata[2]
	var bone_offsets = hdata[3]
	
	return parse_motion(root_bone_name, bone_names, bone_index_map, bone_offsets, motion_lines, config)

# 解析BVH文本
func parse_bvh(fulltext: String) -> Array:
	var lines = fulltext.split("\n", false)
	var hierarchy_lines = []
	var motion_lines = []
	var hierarchy_section = false
	var motion_section = false
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("HIERARCHY"):
			hierarchy_section = true
			motion_section = false
			continue
		elif line.begins_with("MOTION"):
			motion_section = true
			hierarchy_section = false
			continue
		
		if hierarchy_section:
			hierarchy_lines.append(line)
		elif motion_section:
			motion_lines.append(line)
	
	return [hierarchy_lines, motion_lines]

# 解析骨骼层次结构
func parse_hierarchy(text: Array) -> Array:
	var bone_names = []
	var bone_index_map = {}
	var bone_offsets = {}
	
	var data_index = 0
	var current_bone = ""
	var root_bone = ""
	
	for line in text:
		line = line.strip_edges()
		if line.begins_with("ROOT"):
			current_bone = line.split(" ", false)[1]
			bone_names.append(current_bone)
			bone_index_map[current_bone] = {}
			bone_offsets[current_bone] = Vector3()
			root_bone = current_bone
		elif line.begins_with("CHANNELS"):
			var data = line.split(" ", false)
			var num_channels = data[1].to_int()
			for c in range(num_channels):
				var chan = data[2 + c]
				bone_index_map[current_bone][chan] = data_index
				data_index += 1
		elif line.begins_with("JOINT"):
			current_bone = line.split(" ", false)[1]
			bone_names.append(current_bone)
			bone_index_map[current_bone] = {}
			bone_offsets[current_bone] = Vector3()
		elif line.begins_with("OFFSET"):
			var data = line.split(" ", false)
			bone_offsets[current_bone].x = data[1].to_float()
			bone_offsets[current_bone].y = data[2].to_float()
			bone_offsets[current_bone].z = data[3].to_float()
	
	return [root_bone, bone_names, bone_index_map, bone_offsets]

func get_test_angle(raw_rotation,trans,bone_name):
	for order in ["XYZ","XZY","YXZ","YZX","ZXY","ZYX"]:
		var root_transform=Transform3D()
		var rotation=bvh_to_godot_quaternion([raw_rotation.x,raw_rotation.y,raw_rotation.z],order)
		root_transform.basis=Basis(rotation)
		var localTrans=root_transform*trans
		var r=localTrans.basis.get_euler()
		print(bone_name,order,[rad_to_deg(r.x),rad_to_deg(r.y),rad_to_deg(r.z)],"orgin:",raw_rotation,"q:",rotation)
	print(bone_name)
# 解析动作数据并创建动画
func parse_motion(root: String, bone_names: Array, bone_index_map: Dictionary, 
				 bone_offsets: Dictionary, text: Array, config: Dictionary) -> Animation:
	var num_frames = 0
	var timestep = 0.033333
	var read_header = true
	
	# 解析头部信息
	while read_header and text.size() > 0:
		read_header = false
		if text[0].begins_with("Frames:"):
			num_frames = text[0].split(" ")[1].to_int()
			text.remove_at(0)
			read_header = true
		if text.size() > 0 and text[0].begins_with("Frame Time:"):
			timestep = text[0].split(" ")[2].to_float()
			text.remove_at(0)
			read_header = true
	
	# 创建动画资源
	var animation = Animation.new()
	animation.length = num_frames * timestep
	
	# 创建重映射后的骨骼名称列表
	var remapped_bone_names = []
	for bone in bone_names:
		var bone_short=bone.get_slice(":",1)
		if config.get(BONE_REMAPPING_JSON, {}).has(bone):
			remapped_bone_names.append(config[BONE_REMAPPING_JSON][bone])
		elif config.get(BONE_REMAPPING_JSON, {}).has(bone_short):
			remapped_bone_names.append(config[BONE_REMAPPING_JSON][bone_short])
		else:
			
			remapped_bone_names.append(bone)
	
	# 创建动画轨道 - 专注于旋转轨道
	var element_track_index_map = {}
	for i in range(len(bone_names)):
		# 使用旋转轨道而不是变换轨道
		var track_index = animation.add_track(Animation.TYPE_ROTATION_3D)
		
		var skeleton_path = config.get(SKELETON_PATH, "Skeleton3D")
		animation.track_set_path(track_index, "%s:%s" % [skeleton_path, remapped_bone_names[i]])
		
		# 设置轨道插值模式为线性
		animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_LINEAR)
		
		element_track_index_map[i] = track_index
	
	var step = 0
	for line in text:
		var values = line.strip_edges().split(" ", false)
		var float_values = []
		for v in values:
			if v.is_valid_float():
				float_values.append(v.to_float())
		
		# 根骨骼的位置数据
		var root_position = Vector3.ZERO
		if not config.get(IGNORE_OFFSETS, false):
			root_position = bone_offsets[bone_names[0]]
		
		# 获取根骨骼的位置通道
		var root_x_idx = bone_index_map[bone_names[0]].get(XPOS, -1)
		var root_y_idx = bone_index_map[bone_names[0]].get(YPOS, -1)
		var root_z_idx = bone_index_map[bone_names[0]].get(ZPOS, -1)
		
		if root_x_idx != -1 and root_x_idx < float_values.size(): 
			root_position.x += float_values[root_x_idx]
		if root_y_idx != -1 and root_y_idx < float_values.size(): 
			root_position.y += float_values[root_y_idx]
		if root_z_idx != -1 and root_z_idx < float_values.size(): 
			root_position.z += float_values[root_z_idx]
		
		root_position *= config.get(TRANSFORM_SCALING, 1.0)
		
		for bone_index in range(len(bone_names)):
			var track_index = element_track_index_map[bone_index]
			var bone_name = bone_names[bone_index]
			
			# 计算旋转
			var raw_rotation = Vector3(0, 0, 0)
			var rot_x_idx = bone_index_map[bone_names[bone_index]].get(XROT, -1)
			var rot_y_idx = bone_index_map[bone_names[bone_index]].get(YROT, -1)
			var rot_z_idx = bone_index_map[bone_names[bone_index]].get(ZROT, -1)
			var pos_x_idx = bone_index_map[bone_names[bone_index]].get(XROT, -1)
			var pos_y_idx = bone_index_map[bone_names[bone_index]].get(YROT, -1)
			var pos_z_idx = bone_index_map[bone_names[bone_index]].get(ZROT, -1)
			var raw_position = Vector3(0, 0, 0)
			if rot_x_idx != -1 and rot_x_idx < float_values.size(): 
				raw_rotation.x = float_values[rot_x_idx]
			if rot_y_idx != -1 and rot_y_idx < float_values.size(): 
				raw_rotation.y = float_values[rot_y_idx]
			if rot_z_idx != -1 and rot_z_idx < float_values.size(): 
				raw_rotation.z = float_values[rot_z_idx]
			if pos_x_idx != -1 and pos_x_idx < float_values.size(): 
				raw_position.x += float_values[pos_x_idx]
			if pos_y_idx != -1 and pos_y_idx < float_values.size(): 
				raw_position.y += float_values[pos_y_idx]
			if pos_z_idx != -1 and pos_z_idx < float_values.size(): 
				raw_position.z += float_values[pos_z_idx]

			# 对于根骨骼，还需要处理位置
				# 创建根骨骼的变换
			var order=trans_ref.get(remapped_bone_names[bone_index],["XYZ",[1,1,1]])
#			确定变换顺序
			var rotation=bvh_to_godot_quaternion([raw_rotation.x,raw_rotation.y,raw_rotation.z],order[0])
			#var rotation=Quaternion.from_euler(Vector3(deg_to_rad(raw_rotation.x),deg_to_rad(raw_rotation.y),deg_to_rad(raw_rotation.z)))
			var root_transform = Transform3D()
			root_transform.origin = raw_position
			root_transform.basis = Basis(rotation)
				
			if bone_index == 0:
				# 添加根骨骼的旋转关键帧
				animation.rotation_track_insert_key(track_index, step * timestep, rotation)
				var skeleton_path = config.get(SKELETON_PATH, "Skeleton3D")
				# 添加根骨骼的位置关键帧
				var position_track = animation.find_track("%s:%s" % [skeleton_path, remapped_bone_names[bone_index]], Animation.TYPE_POSITION_3D)
				if position_track == -1:
					position_track = animation.add_track(Animation.TYPE_POSITION_3D)
					animation.track_set_path(position_track, "%s:%s" % [skeleton_path, remapped_bone_names[bone_index]])
					
					#animation.track_set_interpolation_type(position_track, Animation.INTERPOLATION_LINEAR)
				
				animation.position_track_insert_key(position_track, step * timestep, root_position)
			else:
				# 对于非根骨骼，只需添加旋转关键帧
				var bone_id=%GeneralSkeleton.find_bone(remapped_bone_names[bone_index])
				
				#bone_id=%GeneralSkeleton.get_bone_parent(bone_id)
#				以下是解析丑陋的实现，线性代数不太好
				if bone_id>0:
					var trans:Transform3D=%GeneralSkeleton.get_bone_rest(bone_id)
					var localTrans=root_transform*trans
					

					var r=localTrans.basis.get_euler()
					#骨架变换修正
					r.x*=order[1][0]
					r.y*=order[1][1]
					r.z*=order[1][2]
					rotation=Quaternion.from_euler(r)
					


				#var rotation_new=rot*rotation
				animation.rotation_track_insert_key(track_index, step * timestep, rotation)
		
		step += 1
	
	return animation
func bvh_to_godot_quaternion(euler_degrees: Array, rotation_order: String) -> Quaternion:
	# 1. 初始化单位四元数
	var q_total = Quaternion.IDENTITY
	
	# 2. 将角度转换为弧度
	var angles_rad = []
	for deg in euler_degrees:
		angles_rad.append(deg_to_rad(deg))
	
	# 3. 定义轴映射（修正Z轴方向问题）
	var axis_map = {
		"X": Vector3.RIGHT,    # (1, 0, 0)
		"Y": Vector3.UP,       # (0, 1, 0)
		"Z": Vector3.FORWARD   # (0, 0, -1)
	}
	
	# 4. 按旋转顺序处理（修正乘法顺序）
	for i in range(rotation_order.length()):
		var axis_char = rotation_order[i]
		var axis = axis_map[axis_char]
		var angle = angles_rad[i]
		
		# 修正Z轴旋转方向（BVH Z+ 匹配 Godot Z-）
		if axis_char == "Z":
			angle = -angle
		
		# 创建当前轴的旋转四元数
		var q_rot = Quaternion(axis, angle)
		
		# 右乘（局部坐标系顺序！）
		q_total = q_total * q_rot  # 关键修正
	
	return q_total


# 将BVH旋转数据转换为四元数
