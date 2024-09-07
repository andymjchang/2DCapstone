extends CharacterBody2D

signal takeDamage(amount)

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var health = 3 # 3 hits
var invuln = false
var attack
var left
var right
var jump
var punch
var enemyscene = preload("res://enemy/enemy.tscn")

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

	print("loading signals")
	self.takeDamage.connect(_onTakeDamage)


#
#func _ready():
	
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

	# If not currently in a song, allow regular movement, otherwise begin autoscroll
	if Globals.inLevel:
		position.x += 2.0
	else:
		pass # Right now just don't give regular controls
		# var direction := Input.get_axis(left, right)
		# if direction:
		# 	velocity.x = direction * SPEED
		# else:
		# 	velocity.x = move_toward(velocity.x, 0, SPEED)

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

func _onTakeDamage(amount):
	print("Got hit!")
	if amount >= 10 or !invuln:		# amount over 10(or some num) means insta-death regardless of invuln
		health -= amount
		print("Health now: ", health)
		if health <= 0:
			print("Player died!")
			self.visible = false
		invuln = true
		await get_tree().create_timer(1.0).timeout
		print("invuln over")
	pass # Replace with function body.
