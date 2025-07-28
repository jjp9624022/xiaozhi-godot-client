extends Node3D
var animition

# Called when the node enters the scene tree for the first time.
func _ready():
	print("启动默认动画")
	animition=$AnimationPlayer
	animition.play("idle")
	
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
