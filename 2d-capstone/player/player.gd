extends CharacterBody2D

signal takeDamage(amount)
signal revive(who)

const SPEED = 388
const JUMP_VELOCITY = -400.0
var health = 3 # 3 hits
var invuln = false
var dead = false
var attack
var canAttack = true
var left
var right
var jump
var punch
var enemyscene = preload("res://enemy/enemy.tscn")

func _ready():
	print("my name is: ",self.name)
	add_to_group("players")
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

	self.takeDamage.connect(_onTakeDamage)
	self.revive.connect(_onRevive)

	
	var enemy_instance= enemyscene.instantiate()
	var enemy_node = enemy_instance.get_node("enemy")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += (1.5 * get_gravity()) * delta
	invuln = true
	#velocity.x = SPEED

	# If not currently in a song, allow regular movement, otherwise begin autoscroll
	if Globals.inLevel:
		velocity.x = SPEED
		#position.x += 2.0
	else:
		pass # Right now just don't give regular controls
		# var direction := Input.get_axis(left, right)
		# if direction:
		# 	velocity.x = direction * SPEED
		# else:
		# 	velocity.x = move_toward(velocity.x, 0, SPEED)

	# Other player mechanics
	if Input.is_action_just_pressed(jump) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed(punch):
		if canAttack:
			print("Punch!")
			attack.disabled = false
			attack.visible = true
			canAttack = false
			await get_tree().create_timer(0.2).timeout
			canAttack = true
			attack.disabled = true
			attack.visible = false


	move_and_slide()

func _onTakeDamage(amount):
	print("Got hit!")
	if !dead and amount >= 10 or !invuln:		# amount over 10(or some num) means insta-death regardless of invuln
		health -= amount

		if health <= 0:
			print("Player died!")
			#self.visible = false
			get_node("ProtoMc").self_modulate.a = 0.5
			dead = true
			invuln = false
			get_parent().emit_signal("checkGameOver")
			if Globals.inLevel:
				await get_tree().create_timer(3.0).timeout
				emit_signal("revive", self)

		else:
			invuln = true
			await get_tree().create_timer(1.0).timeout
			print("invuln over")
			invuln = false
	pass # Replace with function body.


func _onRevive(who):
	who.get_node("ProtoMc").self_modulate.a = 1
	who.health = 3
	who.dead = false
