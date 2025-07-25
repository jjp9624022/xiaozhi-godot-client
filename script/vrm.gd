extends VRMTopLevel
signal speek_info
signal tts
@export var human_status:HumanState
@onready var eye_animation_tree=$AnimationPlayer/eyeAnimation
@onready var camera = $Camera3D
@onready var head=$GeneralSkeleton/Head
var left_eye
var right_eye
var can_move=true
@export var recorder:XiaozhiConect
# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
#绑定姿态交互事件
	human_status.changed.connect(status_change.bind(human_status))
	%GeneralSkeleton.pose_touch.connect(body_act)
func body_act(bone_name,trans_name):
#TODO 完善整个交互的逻辑
	var msg={
		"act":"碰触",
		"bone":bone_name,
		"name":trans_name,
		"target":"assistant"
	}
	
	recorder.send_body_act(JSON.stringify(msg))
	print("碰触了"+trans_name)
	pass
	
func status_change(sta:HumanState):
	#print("调用成功")
	if sta.state==HumanState.status.IDLE:
		recorder.stop_capture()
	elif sta.state==HumanState.status.SPEEKING:
#		降低mic音量，粗糙的避免
		recorder.set_listening_lever(-10)
		#recorder.stop_capture()
	elif sta.state==HumanState.status.LESTENING:
		recorder.set_listening_lever(1)
		recorder.start_capture()
	elif sta.state==HumanState.status.LESTEN_TEXT:
		recorder.send_text(sta.text_to_send)
	#elif sta.state==Human_state.status.TTS

func _receive_data(draging):
	if  draging:
		can_move=false
	else:
		can_move=true
	
func _input(event):
	if event is InputEventMouseMotion and can_move:
		if event.button_mask==MOUSE_BUTTON_MASK_LEFT:
			get_tree().root.position+=Vector2i(event.relative)

func my_look_at_from_position(eye,eye_pos, target_pos, up_direction):
	var direction = (target_pos - eye_pos).normalized()
	eye.transform= Transform3D().looking_at(direction, up_direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tag=head.position
	var pos_2d = camera.unproject_position(tag)
	var mouse_pos = get_viewport().get_mouse_position()
	var direction = (pos_2d-mouse_pos).normalized()
	eye_animation_tree["parameters/blend_position"]=direction
	$AnimationPlayer/AnimationTree["parameters/BlendTree/BlendSpace2D/blend_position"]=direction
