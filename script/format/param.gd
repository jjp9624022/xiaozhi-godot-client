@tool
extends ResourceFormatLoader

# 支持的扩展名
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["param"])

# 资源类型
func _get_resource_type(path: String) -> String:
	return "ConfigResource"

# 处理优先级
func _handles_type(type: StringName) -> bool:
	return type == "ConfigResource"

# 加载资源
func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return FAILED
	
	var content = file.get_as_text()
	file.close()
	
	var resource = ConfigResource.new()
	resource.from_string(content)
	
	# 自动升级旧资源

	
	return resource
