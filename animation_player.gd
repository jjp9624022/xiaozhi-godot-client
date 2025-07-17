extends AnimationPlayer

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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_recorder_is_listening(speek_status) -> void:
	if speek_status:
		
		$eyeAnimation.active=false
		$AnimationTree["parameters/BlendTree/Blend2/blend_amount"]=0.2

	else:
		$eyeAnimation.active=true
		$AnimationTree["parameters/BlendTree/Blend2/blend_amount"]=0.5
func _on_emotion_res(motion_name):
	if motion_dic.get(motion_name):
		$AnimationTree["parameters/BlendTree/emotion/playback"].travel("Start")
		$AnimationTree.set("parameters/BlendTree/emotion/conditions/%s"%motion_dic[motion_name],true)
		$emotion_timer.start(1)


func _on_emotion_timer_timeout() -> void:
	$AnimationTree["parameters/BlendTree/emotion/playback"].travel("blink")
	pass # Replace with function body.
