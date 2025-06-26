@tool
class_name VRMTopLevel
extends Node3D

const vrm_meta_class = preload("./vrm_meta.gd")
const spring_bone_class = preload("./vrm_spring_bone.gd")
const collider_class = preload("./vrm_collider.gd")
const collider_group_class = preload("./vrm_collider_group.gd")
signal test_button_pressed


@export var vrm_meta: Resource = (func():
	var ret: vrm_meta_class = vrm_meta_class.new()
	ret.resource_name = "CLICK TO SEE METADATA"
	return ret
).call()

@export_category("Springbone Settings")
@export var update_secondary_fixed: bool = false
@export var disable_colliders: bool = false
@export var override_springbone_center: bool = false

@export var default_springbone_center: Node3D
@export var springbone_gravity_multiplier: float = 1.0
@export var springbone_gravity_rotation: Quaternion = Quaternion.IDENTITY
@export var springbone_add_force: Vector3 = Vector3.ZERO

@export_category("Run in Editor")
@export var update_in_editor: bool = false
@export var gizmo_spring_bone: bool = false
@export var gizmo_spring_bone_color: Color = Color.LIGHT_YELLOW

@export var spring_bones: Array[spring_bone_class]
@export var collider_groups: Array[collider_group_class]
@export var collider_library: Array[collider_class]



var web
signal speek_info
@onready var animation_tree=$AnimationPlayer/AnimationTree
@onready var eye_animation_tree=$AnimationPlayer/eyeAnimation
@onready var skeleton:Skeleton3D = $GeneralSkeleton
@onready var camera = $Camera3D
@onready var face:MeshInstance3D=$GeneralSkeleton/Face
#@onready var skeleton:Skeleton3D=$"GeneralSkeleton"
@onready var animation_web=$GeneralSkeleton/Animation_web
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
	var tag=$GeneralSkeleton/Head.position
	var pos_2d = camera.unproject_position(tag)
	var mouse_pos = get_viewport().get_mouse_position()
	var direction = (pos_2d-mouse_pos).normalized()
	eye_animation_tree["parameters/blend_position"]=direction
	$AnimationPlayer/AnimationTree["parameters/BlendTree/BlendSpace2D/blend_position"]=direction

	

	pass


func ws_intent_manage(msg:Dictionary):
	var msg_json
	if msg.type=="motion":
		var json = JSON.new()
		var error=json.parse(msg.motion)
		
		if error == OK:
			var data_received = json.data
			animation_web.action_mannge(data_received)


		#print(msg_json)
	elif msg.type=="audio":
		if msg.contents:
			audio_mannage(msg.contents)
		
		
func audio_mannage(payload):

	
	var audio:PackedByteArray=PackedByteArray(Marshalls.base64_to_raw(payload))
	var stream=AudioStreamWAV.new()
	stream.data=audio
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	$AudioStreamPlayer.stream=stream
	$AudioStreamPlayer.play()



func _on_web_socket_client_text_received(peer, message):
	var msg=JSON.parse_string(message)
	#tts.speek(msg.payload)
	print("收到消息")
	ws_intent_manage(msg)



func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("收到消息")
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:

	#tts.speek(msg.payload)
	
		ws_intent_manage(json)
	else:
	#print("发出消息",json["type"])
		pass # Replace with function body.


func _on_button_pressed() -> void:
	test_button_pressed.emit()
	var json=JSON.stringify({"type":"audio","text":"你好，想你了"})
	var headers= ["Content-Type: application/json"]
	$HTTPRequest.request("http://192.168.0.2:1880/audio", headers, HTTPClient.METHOD_POST, json)

	
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	var json=JSON.stringify({"type":"motion","text":"你好，想你了"})
	var headers= ["Content-Type: application/json"]
	$HTTPRequest.request("http://192.168.0.2:1880/motion", headers, HTTPClient.METHOD_POST, json)
	pass # Replace with function body.





func _on_listen_button_down() -> void:
	recorder.start_capture()
	pass # Replace with function body.


func _on_listen_button_up() -> void:
	recorder.stop_capture()
	pass # Replace with function body.
