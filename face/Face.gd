extends Node

# 嘴型权重属性
@export_range(0.0, 1.0) var _min_sound = 0.12
@export var transition_speed: float = 5.0  # 状态过渡速度

# 动画树状态机
@onready var animation_tree: AnimationTree = $"../../AnimationPlayer/AnimationTree"
@onready var state_machine = animation_tree["parameters/BlendTree/speek/playback"] if animation_tree else null

# 元音到状态名称的映射
var _vowel_mapping: Dictionary = {
	LipSync.VISEME.VISEME_E: "ee",
	LipSync.VISEME.VISEME_I: "ih",
	LipSync.VISEME.VISEME_O: "oh",
	LipSync.VISEME.VISEME_U: "ou",
	LipSync.VISEME.VISEME_AA: "aa"
}

# 辅音到元音的映射
var _consonant_mapping: Dictionary = {
	LipSync.VISEME.VISEME_CH: LipSync.VISEME.VISEME_I,   # CH -> I
	LipSync.VISEME.VISEME_DD: LipSync.VISEME.VISEME_E,   # DD -> E
	LipSync.VISEME.VISEME_FF: LipSync.VISEME.VISEME_U,   # FF -> U
	LipSync.VISEME.VISEME_PP: LipSync.VISEME.VISEME_O,   # PP -> O
	LipSync.VISEME.VISEME_RR: LipSync.VISEME.VISEME_AA,  # RR -> AA
	LipSync.VISEME.VISEME_SS: LipSync.VISEME.VISEME_I,   # SS -> I
	LipSync.VISEME.VISEME_TH: LipSync.VISEME.VISEME_I,   # TH -> I
	LipSync.VISEME.VISEME_KK: LipSync.VISEME.VISEME_AA,  # KK -> AA
	LipSync.VISEME.VISEME_NN: LipSync.VISEME.VISEME_E    # NN -> E
}

# 当前嘴型状态
var current_state = "neutral"
var target_state = "neutral"
var last_state_change_time = 0.0

@onready var lip_sync = $"../../LipSync"
@onready var anim_player = $"../../AnimationPlayer"

func _ready():
	# 确保动画树已初始化
	if animation_tree:
		animation_tree.active = true
	else:
		push_error("AnimationTree not found!")

func _physics_process(delta):
	update_mouth_state(delta)

#func _on_timer_timeout():
	#anim_player.play("blink")
	#timer.wait_time = randf_range(2.0, 5.0)
	#timer.start()

# 主更新函数
func update_mouth_state(delta: float):
	var visemes = lip_sync.visemes
	
	# 确保visemes数组有正确的大小
	if visemes.size() != LipSync.VISEME.COUNT:
		return
	
	# 1. 检测是否有说话
	var max_value = 0.0
	for i in range(visemes.size()):
		if visemes[i] > max_value:
			max_value = visemes[i]
	
	# 2. 确定当前目标状态
	var new_target_state = "neutral"
	
	if max_value > _min_sound:
		# 找到最活跃的元音
		var max_vowel_value = 0.0
		var max_vowel_index = LipSync.VISEME.VISEME_SILENT
		
		for viseme in _vowel_mapping:
			if visemes[viseme] > max_vowel_value:
				max_vowel_value = visemes[viseme]
				max_vowel_index = viseme
		
		# 找到最活跃的辅音
		var max_consonant_value = 0.0
		var max_consonant_index = LipSync.VISEME.VISEME_SILENT
		
		for viseme in _consonant_mapping:
			if visemes[viseme] > max_consonant_value:
				max_consonant_value = visemes[viseme]
				max_consonant_index = viseme
		
		# 确定目标状态
		if max_vowel_value >= max_consonant_value:
			new_target_state = _vowel_mapping.get(max_vowel_index, "neutral")
		else:
			# 将辅音映射到对应的元音
			var mapped_vowel = _consonant_mapping.get(max_consonant_index, LipSync.VISEME.VISEME_SILENT)
			new_target_state = _vowel_mapping.get(mapped_vowel, "neutral")
	
	# 3. 更新目标状态
	target_state = new_target_state
	#print("目标嘴型",target_state)
	
	# 4. 检查是否需要状态切换
	if target_state != current_state:
		# 检查状态切换是否完成
		if animation_tree and state_machine:
			var current_node = state_machine.get_current_node()
			
			# 如果当前节点不是目标状态，切换到目标状态
			if current_node != target_state:
				state_machine.travel(target_state)
		
		# 更新当前状态
		current_state = target_state
		last_state_change_time = Time.get_ticks_msec()
	#elif animation_tree and state_machine:
		## 确保保持在当前状态
		#if state_machine.get_current_node() != current_state:
			#state_machine.travel(current_state)

# 辅助函数：获取状态持续时间（毫秒）
func get_state_duration():
	if animation_tree:
		return animation_tree.get("parameters/BlendTree/%s/playback_speed" % current_state) * 1000
	return 0.0
