extends Node3D
signal speek_info
signal tts
@onready var animation_tree=$AnimationPlayer/AnimationTree
@onready var eye_animation_tree=$AnimationPlayer/eyeAnimation
@onready var skeleton:Skeleton3D = $GeneralSkeleton
@onready var camera = $Camera3D
@onready var face:MeshInstance3D=$GeneralSkeleton/Face
#@onready var skeleton:Skeleton3D=$"GeneralSkeleton"
@onready var animation_web=$GeneralSkeleton/Animation_web
@onready var head=$GeneralSkeleton/Head
var left_eye
var right_eye
@onready var recorder=$recorder
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.set_transparent_background(true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)

			


	#left_eye=
	
	
	animation_tree.active=true
	 # Replace with function body.
	
func _input(event):
	if event is InputEventMouseMotion:
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
func get_tts(msg):
	tts.emit(msg)
#处理文字信息	
func send_text(text):
	recorder.send_text(text)
	#pass

func start_send_audio() -> void:
	recorder.start_capture()
	pass # Replace with function body.


func stop_send_audio() -> void:
	recorder.stop_capture()
	pass # Replace with function body.
