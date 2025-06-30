extends Node2D

# Example script to demonstrate AI Coding Assistant features
# Try selecting parts of this code and using the "Explain" or "Improve" buttons
# Or ask the AI to generate new code for you!

@export var speed: float = 100.0
@export var health: int = 100

var velocity: Vector2 = Vector2.ZERO
var is_moving: bool = false

signal health_changed(new_health: int)
signal player_died()

func _ready():
	print("Player initialized with health: ", health)
	health_changed.connect(_on_health_changed)

func _process(delta):
	handle_input()
	move_player(delta)

func handle_input():
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	velocity = velocity.normalized() * speed
	is_moving = velocity.length() > 0

func move_player(delta: float):
	if is_moving:
		position += velocity * delta

func take_damage(amount: int):
	health -= amount
	health = max(0, health)
	health_changed.emit(health)
	
	if health <= 0:
		die()

func heal(amount: int):
	health += amount
	health = min(100, health)  # Cap at 100
	health_changed.emit(health)

func die():
	print("Player died!")
	player_died.emit()
	# Add death logic here

func _on_health_changed(new_health: int):
	print("Health changed to: ", new_health)
	
	# You could update UI here
	if new_health < 20:
		print("Warning: Low health!")

# Try asking the AI to:
# 1. "Add a jump function to this player script"
# 2. "Create a inventory system for this player"
# 3. "Optimize this movement code"
# 4. "Add animation support to this script"
