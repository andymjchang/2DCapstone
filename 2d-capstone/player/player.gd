extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var inLevel = false
var attack
var left
var right
var jump
var punch

func _ready():
	print("my name is: ",self.name)
	# Controls for player1
	if self.name == "Player1":
		left = "left1"
		right = "right1"
		jump = "jump1"
		punch = "punch1"
	elif self.name == "Player2":
		left = "left2"
		right = "right2"
		jump = "jump2"
		punch = "punch2"

	attack = get_node("AttackHitbox")
	print("attack loaded")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If not currently in a song, allow regular movement, otherwise begin autoscroll
	if !inLevel:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis(left, right)
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 1.0 * SPEED

	# Other player mechanics
	if Input.is_action_just_pressed(jump) and is_on_floor():
		print("Jump!")
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed(punch):
		attack.disabled = false
		attack.visible = true
		print("Punch!")
		await get_tree().create_timer(0.2).timeout
		print("Punch over")
		attack.disabled = true
		attack.visible = false

	move_and_slide()