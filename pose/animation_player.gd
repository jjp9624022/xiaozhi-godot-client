extends AnimationPlayer
@export var human_status:HumanState
@export var xiaozhi:XiaozhiConect
@onready var motion_dic={
	"sad":"sad",
	"relaxed":"relaxed",
	"angry":"angry",
	"happy":"happy",
	"surprised":"surprised",
	"thinking":"blink",
	"laughing":"happy",
	"neutral":"neutral"
}
var emoji_map = {
	"neutral": "😶",
	"happy": "🙂",
	"laughing": "😆",
	"funny": "😂",
	"sad": "😔",
	"angry": "😠",
	"crying": "😭",
	"loving": "😍",
	"embarrassed": "😳",
	"surprised": "😲",
	"shocked": "😱",
	"thinking": "🤔",
	"winking": "😉",
	"cool": "😎",
	"relaxed": "😌",
	"delicious": "🤤",
	"kissy": "😘",
	"confident": "😏",
	"sleepy": "😴",
	"silly": "😜",
	"confused": "🙄",
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	xiaozhi.emotion_state.connect(_on_emotion_res)
	human_status.changed.connect(_on_recorder_is_listening.bind(human_status))

func _on_recorder_is_listening(speek_status:HumanState) -> void:
	if speek_status.state==HumanState.status.LESTENING:
		#print("调用次数")
		$eyeAnimation.active=false
		$AnimationTree["parameters/BlendTree/Blend2/blend_amount"]=0.05

	else:
		$eyeAnimation.active=true
		$AnimationTree["parameters/BlendTree/Blend2/blend_amount"]=0.1
	pass
func _on_emotion_res(motion_name):
	if motion_dic.get(motion_name):
		$AnimationTree["parameters/BlendTree/emotion/playback"].travel(motion_dic[motion_name])
		#$AnimationTree.set("parameters/BlendTree/emotion/conditions/%s"%motion_dic[motion_name],true)
		#$emotion_timer.start(3)
