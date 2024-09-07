extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var enemyscene = preload("res://enemy/enemy.tscn")

func _ready():
	
	var enemy_instance= enemyscene.instantiate()
	var enemy_node = enemy_instance.get_node("enemy")
	print("in player eady")
	
	if enemy_node:
		print("in if")
		enemy_node.connect("playerspotted", Callable(func(): print("Clicked")))
	

func _on_playerspotted() -> void:
	print("enemy spotted me!")
	
func handleplayerspotted():
	print("enemy has spotted me!")
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
