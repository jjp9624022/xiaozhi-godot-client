extends Node
var animation 
func _enter_tree():
	print("启动动画")
	#animation==$AnimationPlayer
	
func _ready():
	print("启动动画")
	animation==$AnimationPlayer
	animation.play("idle")
	
