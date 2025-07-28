# SettingsUI.gd
extends CanvasLayer

@onready var master_slider: HSlider = %MasterSlider
@onready var voice_slider: HSlider = %VoiceSlider
@onready var mic_slider: HSlider = %MicSlider
@onready var server_url_edit: LineEdit = %ServerUrlEdit
@onready var face_server_url_edit: LineEdit = %FaceServerUrlEdit
@onready var test_connection_button: Button = %TestConnectionButton
@onready var status_label: Label = %StatusLabel

var settings: GameSettings

func _ready():
	# 加载设置
	settings = GameSettings.load_or_create()
	load_settings()
	
	# 连接信号
	master_slider.value_changed.connect(_on_master_changed)
	voice_slider.value_changed.connect(_on_voice_changed)
	mic_slider.value_changed.connect(_on_mic_changed)
	server_url_edit.text_changed.connect(_on_server_url_changed)
	face_server_url_edit.text_changed.connect(_on_face_server_url_changed)
	test_connection_button.pressed.connect(_on_test_connection_pressed)

func load_settings():
	master_slider.value = settings.master_volume
	voice_slider.value = settings.voice_volume
	mic_slider.value = settings.mic_volume
	server_url_edit.text = settings.server_url
	face_server_url_edit.text=settings.face_server_url
	
	# 应用初始设置
	_on_master_changed(settings.master_volume)
	_on_voice_changed(settings.voice_volume)
	_on_mic_changed(settings.mic_volume)

	status_label.text = "设置已加载"
# 信号处理函数
func _on_master_changed(value: float):
	settings.master_volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))
	status_label.text = "主音量: %d%%" % value

func _on_voice_changed(value: float):
	settings.voice_volume = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value / 100.0))
	status_label.text = "tts语音音量: %d%%" % value
func _on_mic_changed(value: float):
	settings.mic_volume = value
	AudioServer.set_bus_volume_db(2, linear_to_db(value / 100.0))
	status_label.text = "录音音量: %d%%" % value

func _on_server_url_changed(new_text: String):
	settings.server_url = new_text
	status_label.text = "服务器路径已更新"
func _on_face_server_url_changed(new_text: String):
	settings.face_server_url = new_text
	status_label.text = "人脸识别服务器下载路径已更新"

func _on_test_connection_pressed():
	status_label.text = "正在测试服务器连接..."
	test_connection_button.disabled = true
	
	# 在实际应用中，这里会添加网络连接测试代码
	# 以下是一个模拟的网络测试
	var test_timer = Timer.new()
	add_child(test_timer)
	test_timer.wait_time = 5.0
	test_timer.one_shot = true
	test_timer.timeout.connect(func(): 
		status_label.text = "连接成功! (%s)" % settings.server_url
		test_connection_button.disabled = false
		test_timer.queue_free()
	)
	test_timer.start()

# 保存按钮处理
func _on_save_button_pressed():
	settings.save()
	status_label.text = "设置已保存!"
	
	# 添加保存成功动画
	var save_icon = %SaveIcon
	save_icon.visible = true
	var tween = create_tween()
	tween.tween_property(save_icon, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(save_icon, "scale", Vector2(1, 1), 0.2)
	tween.tween_interval(0.5)
	tween.tween_callback(func(): save_icon.visible = false)

# 重置按钮处理
func _on_reset_button_pressed():
	settings = GameSettings.new()
	load_settings()
	status_label.text = "设置已重置为默认值"


func _on_close_pressed() -> void:
	queue_free()
	pass # Replace with function body.


func _on_face_check_button_button_down() -> void:
	#get_parent()
	set_process(true)
	var loader = ResourceLoader.load_threaded_request("res://face_reg.tscn")
	pass # Replace with function body.


func _on_face_check_button_button_up() -> void:
	var face=get_parent().get_node("face_reg")
	get_parent().remove_child(face)
	set_process(false)
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status("res://face/face_reg.tscn", progress)
	if status==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		print("加载中",progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get("res://face/face_reg.tscn")
		var instance = scene.instantiate()
		get_parent().add_child(instance)
		set_process(false)
