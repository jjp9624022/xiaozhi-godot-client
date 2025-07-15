@tool
extends Resource
class_name BinaryDataResource

@export var binary_data: PackedByteArray

@export var version: int = 1

func get_binary_data() -> PackedByteArray:
	return binary_data
# 字符串数组
@export var strings: PackedStringArray = PackedStringArray()

# 添加字符串
func add_string(s: String):
	strings.append(s)
	emit_changed()

# 删除字符串
func remove_string(index: int):
	if index >= 0 and index < strings.size():
		strings.remove_at(index)
		emit_changed()



# 从字符串加载
func from_string(data: String):
	strings = data.split("\n", false)

# 资源升级（兼容旧版本）
func upgrade():
	if version == 1:
		# 升级逻辑示例
		var upgraded = PackedStringArray()
		for s in strings:
			upgraded.append(s.strip_edges())
		strings = upgraded
		version = 2
