@tool
extends Resource
class_name ConfigResource

@export var string_data: PackedStringArray

func get_String_data() -> PackedStringArray:
	return string_data
