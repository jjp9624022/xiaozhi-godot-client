extends AnimationPlayer

@onready var motion_dic={
	"sad":"sad",
	"relaxed":"relaxed",
	"angry":"angry",
	"happy":"happy",
	"surprised":"surprised",
	"thinking":"mix/thinking",
	"laughing":"mix/laughing"
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
	if motion_dic[motion_name]:
		self.play(motion_dic[motion_name])
