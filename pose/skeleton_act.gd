extends Skeleton3D
var bone_names_map = {
	"LeftLowerArm": "左小臂",
	"LeftUpperArm": "左上臂",
	"LeftShoulder": "左肩",
	"Neck": "颈部",
	"RightShoulder": "右肩",
	"RightUpperArm": "右上臂",
	"RightLowerArm": "右小臂",
	"UpperChest": "上胸部",
	"Chest": "胸部",
	"Hips": "臀部",
	"LeftUpperLeg": "左大腿",
	"RightUpperLeg": "右大腿",
	"LeftLowerLeg": "左小腿",
	"LeftFoot": "左脚",
	"RightLowerLeg": "右小腿",
	"RightFoot": "右脚",
	"LeftHand":"左手",
	"RightHand":"右手",
	"Head":"头"
}
	#这是特殊的互动关节
@onready var pose_bone:Array=[$LeftHand,$RightHand,$Head/Head]
signal pose_touch
func _ready() -> void:
#	初始化普通关节
	for bone_name in bone_names_map:
		if bone_name in ["LeftHand","RightHand","Head"]:continue
		var bone_id =find_bone(bone_name)
		var attech_bone=BoneAttachment3D.new()
		attech_bone.bone_idx=bone_id
		attech_bone.attech_bone=false
		add_child(attech_bone)
		var act_box=load("res://pose/pose_act_box.tscn")
		var box:PoseActor=act_box.instantiate()
		attech_bone.add_child(box)
		box.name=bone_name
		box.draging.connect(pose_act.bind(box))
		
#初始化手和头的特殊互动关节		
	for bone_ik in pose_bone:
		bone_ik.act.connect(pose_act.bind(bone_ik))
		
func pose_act(bone_ik):
	pose_touch.emit(bone_ik.name,bone_names_map[bone_ik.name])
	#print("碰触",bone_names_map[bone_ik.name])
