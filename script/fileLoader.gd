extends Node

# 原生插件实例
var native_loader = null

func _ready():
	# 初始化原生插件
	pass
# 使用 ResourceLoader 加载资源
func load_and_process_resource(resource_path: String,format:String=""):
	# 使用 ResourceLoader 安全加载资源
	var resource = ResourceLoader.load(resource_path, format, ResourceLoader.CACHE_MODE_IGNORE)
	
	if resource:
		print("Resource loaded successfully: ", resource_path)
		
		# 处理资源数据
		#process_resource(resource)
		
		# 保存用户数据副本（如果需要）
		return save_user_data_copy(resource)
	else:
		push_error("Failed to load resource: " + resource_path)

# 处理资源数据（示例）

	# 添加其他资源类型处理

# 保存用户数据副本
func save_user_data_copy(resource):
	var user_path
	# 只有需要原生插件访问时才保存副本
	if resource is BinaryDataResource:
		user_path = "user://data/" + resource.resource_path.get_file()
		var data = resource.get_binary_data()
		
		# 保存到 user 目录
		save_binary_to_user(data, user_path)
	elif resource is ConfigResource:
		var data=resource.get_String_data()
		save_string_array_to_user(data, user_path)
	return user_path
		# 传递给原生插件


# 保存二进制数据到 user 目录
func save_binary_to_user(data: PackedByteArray, path: String):
	var dir = DirAccess.open("user://")
	if !dir.dir_exists(path.get_base_dir()):
		dir.make_dir_recursive(path.get_base_dir())
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_buffer(data)
		print("Data saved to user://", path)
	else:
		push_error("Failed to save data: " + path)
# 将 PackedStringArray 保存到 user 目录下的文件
func save_string_array_to_user(data: PackedStringArray, path: String):
	# 确保目标目录存在
	var dir_path = path.get_base_dir()
	if !dir_path.is_empty() && !DirAccess.dir_exists_absolute("user://" + dir_path):
		var err = DirAccess.make_dir_recursive_absolute("user://" + dir_path)
		if err != OK:
			push_error("Failed to create directory: user://" + dir_path)
			return
	
	# 打开文件进行写入
	var file = FileAccess.open("user://" + path, FileAccess.WRITE)
	if file:
		# 遍历数组中的每个字符串
		for i in range(data.size()):
			# 写入字符串并添加换行符
			file.store_line(data[i])
		
		print("String array saved to user://", path)
		return true
	else:
		push_error("Failed to save string array: user://" + path)
		return false
