extends CharacterBody2D

signal takeDamage(amount)
signal revive(who)
signal relocate(nearestPoint)

const SPEED = 388.0
const JUMP_VELOCITY = -400.0
var health = 99999999 # 3 hits
var invuln = false
var dead = false
var attack
var canAttack = true
var left
var right
var jump
var punch
var reachedCheckpoint = true
var relocating = false
var enemyscene = preload("res://enemy/enemy.tscn")
var checkpoint
var otherPlayer
var editing = false
var index = 0

func _ready():
	print("my name is: ",self.name)
	add_to_group("players")
	# Controls for player1
	if self.name == "Player1":
		left = "left1"
		right = "right1"
		jump = "jump1"
		punch = "punch1"
		otherPlayer = "Player2"
	elif self.name == "Player2":
		left = "left2"
		right = "right2"
		jump = "jump2"
		punch = "punch2"
		otherPlayer = "Player1"

	attack = get_node("AttackHitbox")

	self.takeDamage.connect(_onTakeDamage)
	self.revive.connect(_onRevive)
	self.relocate.connect(_onRelocate)


func _physics_process(delta: float) -> void:
	if not editing:
		if not relocating:
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta * 2

			#velocity.x = SPEED

			# If not currently in a song, allow regular movement, otherwise begin autoscroll
			if Globals.inLevel:
				velocity.x = SPEED
				#position.x += 2.0
			else:
				#pass # Right now just don't give regular controls
				var direction = Input.get_axis(left, right)
				if direction:
					velocity.x = direction * SPEED
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)

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
		elif reachedCheckpoint:
			# Wait to respawn relocating player when teammate has aligned
			if get_parent().get_node(otherPlayer).position.x >= self.position.x:
				# Reset relocating player position and allow control
				get_node("CollisionShape2D").call_deferred("set", "disabled", false)
				relocating = false
				reachedCheckpoint = true
				self.position.y = checkpoint.get_node("Point").position.y
				self.position.x = get_parent().get_node(otherPlayer).position.x
			pass
		move_and_slide()

func _onTakeDamage(amount):
	print("Got hit! Health now: ", self.health)
	if !dead or amount >= 10 or !invuln:		# amount over 10(or some num) means insta-death regardless of invuln
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


func _onRevive(who):
	who.get_node("ProtoMc").self_modulate.a = 1
	who.health = 3
	who.dead = false

func _onRelocate(nearestPoint):
	# Disable collisions, change flags for relocation
	get_node("CollisionShape2D").call_deferred("set", "disabled", true)
	relocating = true
	reachedCheckpoint = false

	# Set destination, begin move to point
	checkpoint = nearestPoint
	velocity.x = (nearestPoint.position.x - position.x) * SPEED/2 * get_process_delta_time()
	velocity.y = (nearestPoint.position.y - position.y) * SPEED/2 * get_process_delta_time()
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("click")
		get_parent().get_parent().get_parent().emit_signal("objectClicked",index)
	pass # Replace with function body.
