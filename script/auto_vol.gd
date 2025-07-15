extends Control

# 音量级别枚举
enum VolumeLevel { LOW, MEDIUM, HIGH, VERY_HIGH }

# 平台特定的音量调整因子
var platform_gain_factors = {
	"Android": 50.0,    # 通常需要最大增益
	"iOS": 30.0,        # iOS设备通常需要中等增益
	"Windows": 1.0,     # Windows通常不需要调整
	"macOS": 1.5,       # macOS可能需要轻微调整
	"Linux": 2.0,       # Linux可能需要调整
	"HTML5": 100.0,     # 浏览器通常需要最大增益
	"unknown": 10.0     # 默认值
}

@onready var audio_stream_player = $"../Mic"
@onready var audio_capture_effect = $"../Mic"/AudioEffectCapture
@onready var audio_amplify_effect = $"../Mic"/AudioEffectAmplify
@onready var spectrum_analyzer = $"../Mic"/AudioEffectSpectrumAnalyzer

# UI 元素
@onready var vu_meter = $VUMeter
@onready var waveform_display = $WaveformDisplay
@onready var platform_label = $PlatformLabel
@onready var gain_label = $GainLabel
@onready var volume_level_label = $VolumeLevelLabel
@onready var gain_slider = $GainSlider

var current_platform = "unknown"
var auto_adjust_gain = true
var target_rms = 0.1  # 目标音量级别 (0-1)
var smoothing_factor = 0.2
var current_rms = 0.0

func _ready():
	# 检测当前平台
	current_platform = OS.get_name()
	platform_label.text = "Platform: " + current_platform
	
	# 设置初始增益
	var initial_gain = platform_gain_factors.get(current_platform, platform_gain_factors["unknown"])
	audio_amplify_effect.volume_db = initial_gain
	gain_slider.value = initial_gain
	update_gain_label()
	
	# 设置麦克风输入
	audio_stream_player.stream = AudioStreamMicrophone.new()
	audio_stream_player.play()
	
	# 开始处理音频
	set_process(true)

func _process(delta):
	# 获取可用的帧数
	var available_frames = audio_capture_effect.get_frames_available()
	if available_frames > 0:
		# 读取样本
		var buffer = audio_capture_effect.get_buffer(available_frames)
		
		# 计算当前RMS值（音量级别）
		var rms = calculate_rms(buffer)
		
		# 平滑RMS值
		current_rms = lerp(current_rms, rms, smoothing_factor)
		
		# 自动调整增益
		if auto_adjust_gain:
			auto_adjust_gain_function(current_rms)
		
		# 更新UI
		update_ui(current_rms)
		
		# 更新波形显示
		update_waveform(buffer)

# 计算音频样本的RMS值
func calculate_rms(buffer: PackedVector2Array) -> float:
	var sum_squares = 0.0
	for sample in buffer:
		# 将立体声样本转换为单声道
		var mono_sample = (sample.x + sample.y) / 2.0
		sum_squares += mono_sample * mono_sample
	
	var mean_square = sum_squares / buffer.size()
	return sqrt(mean_square)

# 自动调整增益
func auto_adjust_gain_function(current_rms: float):
	if current_rms < 0.001:  # 静音检测
		return
	
	var current_gain = audio_amplify_effect.volume_db
	var target_gain = linear_to_db(target_rms / current_rms) + current_gain
	
	# 应用增益调整（带限制）
	var new_gain = clamp(target_gain, -30.0, 50.0)
	audio_amplify_effect.volume_db = lerp(current_gain, new_gain, 0.1)
	gain_slider.value = new_gain
	update_gain_label()

# 更新UI
func update_ui(rms: float):
	# 更新VU表
	vu_meter.value = rms * 100
	
	# 更新音量级别标签
	var volume_level = get_volume_level(rms)
	volume_level_label.text = "Volume Level: " + VolumeLevel.keys()[volume_level]
	
	# 设置标签颜色基于音量级别
	match volume_level:
		VolumeLevel.LOW:
			volume_level_label.add_theme_color_override("font_color", Color.YELLOW)
		VolumeLevel.MEDIUM:
			volume_level_label.add_theme_color_override("font_color", Color.GREEN)
		VolumeLevel.HIGH:
			volume_level_label.add_theme_color_override("font_color", Color.ORANGE)
		VolumeLevel.VERY_HIGH:
			volume_level_label.add_theme_color_override("font_color", Color.RED)

# 获取音量级别
func get_volume_level(rms: float) -> VolumeLevel:
	if rms < 0.01:
		return VolumeLevel.LOW
	elif rms < 0.05:
		return VolumeLevel.MEDIUM
	elif rms < 0.1:
		return VolumeLevel.HIGH
	else:
		return VolumeLevel.VERY_HIGH

# 更新波形显示
func update_waveform(buffer: PackedVector2Array):
	waveform_display.update_waveform(buffer)

# 更新增益标签
func update_gain_label():
	gain_label.text = "Gain: %.1f dB" % audio_amplify_effect.volume_db

# UI 回调函数
func _on_gain_slider_value_changed(value):
	audio_amplify_effect.volume_db = value
	auto_adjust_gain = false
	update_gain_label()

func _on_auto_adjust_toggled(button_pressed):
	auto_adjust_gain = button_pressed

func _on_reset_gain_pressed():
	var default_gain = platform_gain_factors.get(current_platform, platform_gain_factors["unknown"])
	audio_amplify_effect.volume_db = default_gain
	gain_slider.value = default_gain
	update_gain_label()
