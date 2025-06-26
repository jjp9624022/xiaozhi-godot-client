# Author: Malcolm Nixon https://github.com/Malcolmnixon
# GitHub Project Page: To be released as a addon for the Godot Engine
# License: MIT

extends MeshInstance3D



@onready var Viseme_Ch : float 
@onready var Viseme_Dd : float 
@onready var Viseme_E : float 
@onready var Viseme_Ff : float
@onready var Viseme_I : float
@onready var Viseme_O : float
@onready var Viseme_Pp : float
@onready var Viseme_Rr : float
@onready var Viseme_Ss : float
@onready var Viseme_Th : float
@onready var Viseme_U : float
@onready var Viseme_AA : float
@onready var Viseme_Kk : float
@onready var Viseme_Nn : float
@onready var Viseme_Sil : float
#设置嘴型识别的阈值
@export var _min_sound=0.12

@onready var lip_sync= $LipSync
@onready var bus = AudioServer.get_bus_index("Speech")
@onready var tween = create_tween()
@onready var timer=$Timer
@onready var anim_player=$"../../AnimationPlayer"
func _ready():
	pass
	#print(lip_sync)

	
func _physics_process(_delta):
	
	
	#print(lip_sync)
	#if lip_sync:
		#print("lip_sync is ok")
	#print (_delta)
	play_motion()
	
	
	#clamp(value, 0.0, 1.0)


func _on_timer_timeout():
	anim_player.play("blink")
	timer.wait_time=randf_range(2.0, 5.0)
	timer.start()
		
func play_motion():
	var list=lip_sync.visemes
	#print(list)
	#var max_item=max(list)
	#print(max_item)
	#set_max_to_one(list)
	var list_opt=set_max_to_one(list)
	#print(list_opt)
	Viseme_Ch = list_opt[LipSync.VISEME.VISEME_CH]
	Viseme_Dd = list_opt[LipSync.VISEME.VISEME_DD]
	Viseme_E = list_opt[LipSync.VISEME.VISEME_E]
	Viseme_Ff = list_opt[LipSync.VISEME.VISEME_FF]
	Viseme_I = list_opt[LipSync.VISEME.VISEME_I]
	Viseme_O = list_opt[LipSync.VISEME.VISEME_O]
	Viseme_Pp = list_opt[LipSync.VISEME.VISEME_PP]
	Viseme_Rr = list_opt[LipSync.VISEME.VISEME_RR]
	Viseme_Ss = list_opt[LipSync.VISEME.VISEME_SS]
	Viseme_Th = list_opt[LipSync.VISEME.VISEME_TH]
	Viseme_U = list_opt[LipSync.VISEME.VISEME_U]
	Viseme_AA =list_opt[LipSync.VISEME.VISEME_AA]
	Viseme_Kk = list_opt[LipSync.VISEME.VISEME_KK]
	Viseme_Nn = list_opt[LipSync.VISEME.VISEME_NN]
	Viseme_Sil = list_opt[LipSync.VISEME.VISEME_SILENT]
	
	#print(Viseme_Kk)

	#self.set("blend_shapes/Fcl_MTH_E", max(Viseme_E,Viseme_Ss,Viseme_Th,Viseme_Nn))
#
	#self.set("blend_shapes/Fcl_MTH_I", max(Viseme_Dd,Viseme_Ch,Viseme_I,Viseme_Rr,Viseme_Sil))
	#self.set("blend_shapes/Fcl_MTH_O", max(Viseme_O,Viseme_Ff,Viseme_Pp))
#
	#self.set("blend_shapes/Fcl_MTH_U", Viseme_U)
	#self.set("blend_shapes/Fcl_MTH_A", max(Viseme_AA,Viseme_Kk))

	
	self.set("blend_shapes/Fcl_MTH_H", Viseme_Ch)
	self.set("blend_shapes/Fcl_MTH_D", Viseme_Dd)
	self.set("blend_shapes/Fcl_MTH_E", Viseme_E)
	self.set("blend_shapes/Fcl_MTH_F", Viseme_Ff)
	self.set("blend_shapes/Fcl_MTH_I", Viseme_I)
	self.set("blend_shapes/Fcl_MTH_O", Viseme_O)
	self.set("blend_shapes/Fcl_MTH_P", Viseme_Pp)
	self.set("blend_shapes/Fcl_MTH_R", Viseme_Rr)
	self.set("blend_shapes/Fcl_MTH_S", Viseme_Ss)
	self.set("blend_shapes/Fcl_MTH_TH", Viseme_Th)
	self.set("blend_shapes/Fcl_MTH_U", Viseme_U)
	self.set("blend_shapes/Fcl_MTH_A", Viseme_AA)
	self.set("blend_shapes/Fcl_MTH_k", Viseme_Kk)
	self.set("blend_shapes/Fcl_MTH_N", Viseme_Nn)
	self.set("blend_shapes/Fcl_MTH_sil", Viseme_Sil)
	
func set_max_to_one(values):
	# 检查列表是否为空
	if values.size() == 0:
		return []

	# 找到最大值
	
	var max_value = values.max()
	if max_value<=_min_sound:
		max_value=_min_sound
		values.fill(0)
		return values
	


	

	# 创建一个新的列表，最大值设置为1，其他设置为0
	var result = []
	var changed=false
	for value in values:
		if value == max_value and changed==false:
			#result.append(1)
			result.append(1)
			changed=true
		else:
			result.append(0)

	return result


	#lerping the silent value to try for smoother transitions
	#self.set("blend_shapes/viseme_sil", lerp(self.get("blend_shapes/viseme_sil"), Viseme_Sil, delta))
	
	#Trying with all lerps - too slow but preserving
	#self.set("blend_shapes/viseme_CH", lerp(self.get("blend_shapes/viseme_CH"), Viseme_Ch, 20*delta))

	#self.set("blend_shapes/viseme_E", lerp(self.get("blend_shapes/viseme_E"), Viseme_E, 20*delta))
	#self.set("blend_shapes/viseme_FF", lerp(self.get("blend_shapes/viseme_FF"), Viseme_Ff, 20*delta))
	#self.set("blend_shapes/viseme_I", lerp(self.get("blend_shapes/viseme_I"), Viseme_I, 20*delta))
	#self.set("blend_shapes/viseme_O", lerp(self.get("blend_shapes/viseme_O"), Viseme_O, 20*delta))
	#self.set("blend_shapes/viseme_PP", lerp(self.get("blend_shapes/viseme_PP"), Viseme_Pp, 20*delta))
	#self.set("blend_shapes/viseme_RR", lerp(self.get("blend_shapes/viseme_RR"), Viseme_Rr, 20*delta))
	#self.set("blend_shapes/viseme_SS", lerp(self.get("blend_shapes/viseme_SS"), Viseme_Ss, 20*delta))
	#self.set("blend_shapes/viseme_TH", lerp(self.get("blend_shapes/viseme_TH"), Viseme_Th, 20*delta))
	#self.set("blend_shapes/viseme_U", lerp(self.get("blend_shapes/viseme_U"), Viseme_U, 20*delta))
	#self.set("blend_shapes/viseme_aa", lerp(self.get("blend_shapes/viseme_aa"), Viseme_AA, 20*delta))

	#self.set("blend_shapes/viseme_nn", lerp(self.get("blend_shapes/viseme_nn"), Viseme_Nn, 20*delta))
	#self.set("blend_shapes/viseme_sil", lerp(self.get("blend_shapes/viseme_sil"), Viseme_Sil, 20*delta))
