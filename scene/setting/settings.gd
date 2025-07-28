# settings.gd
class_name GameSettings
extends Resource

# 定义可导出的设置属性
@export_range(0, 100) var master_volume: int = 100
@export_range(0, 100) var voice_volume: int = 100
@export_range(0, 100) var mic_volume: int = 100

@export var server_url: String = "ws://192.168.1.1:8000/xiaozhi/v1"  # 服务器路径设置
@export var face_server_url: String = "http://localhost:5000"  # 服务器路径设置
var server_state:bool=false
# 保存设置到文件
func save() -> void:
	ResourceSaver.save(self, "user://settings.tres")
func set_server_state(state):
	server_state=state
	changed.emit()
# 加载设置
static func load_or_create() -> GameSettings:
	if ResourceLoader.exists("user://settings.tres"):
		return ResourceLoader.load("user://settings.tres")
	return GameSettings.new()
