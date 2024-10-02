extends CharacterBody2D

signal takeDamage(amount)
signal revive(who)
signal relocate(nearestPoint)
signal scored(id, score)

var curSprite
var JUMP_VELOCITY = -550.0
var SPEED = 400.0
var health = 27 # 3 hits
var blockType = "player"
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
var checkpoint
var otherPlayer
var editing = false
var index = 0

var jumpInProgress = false
var punchInProgress = false
var runInProgress = false

var otherPlayerList
var worldNode

func _ready():
	print("my name is: ",self.name)
	curSprite = get_node("Animation").duplicate()
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
	self.attack.visible = false
	$Animation.animation_finished.connect(_onAnimationFinished)
	
	worldNode = get_tree().get_root().get_node("level")
	self.scored.connect(worldNode._onScored)

func _physics_process(delta: float) -> void:
	if not editing:
		if not relocating:
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta * 2

			#velocity.x = SPEED

			# If not currently in a song, allow regular movement, otherwise begin autoscroll
			if Globals.inLevel:
				velocity.x = Globals.pixelsPerFrame
				if not jumpInProgress and not punchInProgress:
					$Animation.play("Run")
				#position.x += 2.0
			else:
				pass # Right now just don't give regular controls
				# var direction = Input.get_axis(left, right)
				# if direction:
				# 	velocity.x = direction * SPEED
				# else:
				# 	velocity.x = move_toward(velocity.x, 0, SPEED)

			# Other player mechanics
			if Input.is_action_just_pressed(jump) and is_on_floor():
				$Animation.play("Jump")
				jumpInProgress = true
				velocity.y = JUMP_VELOCITY
				#await get_tree().create_timer(0.2).timeout
			
			if Input.is_action_just_pressed(punch):
				if canAttack:
					$Animation.play("Punch")
					punchInProgress = true
					#print("Punch!")
					attack.visible = true
					attack.monitoring = true
					canAttack = false
					$attackTimer.start()

		elif reachedCheckpoint:
			# Wait to respawn relocating player when teammate has aligned
			if get_parent().get_node(otherPlayer).position.x >= self.position.x:
				print("My name: ", name)
				print("Made it")
				emit_signal("revive")
				# Reset relocating player position and allow control
				get_node("CollisionShape2D").call_deferred("set", "disabled", false)
				relocating = false
				reachedCheckpoint = false
				invuln = false
				#self.position.y = checkpoint.get_node("Point").position.y
				self.position.x = get_parent().get_node(otherPlayer).position.x
		move_and_slide()
	else:
		invuln = true

func _onTakeDamage(amount):
	if !dead or amount >= 10 or !invuln:		# amount over 10(or some num) means insta-death regardless of invuln
		health -= amount
		#print("Got hit! Health now: ", self.health)
		if health % 9 == 0:
			get_parent().get_parent().get_parent().get_node("HealthManager").emit_signal("decreaseHealth", self.name)
		if health <= 0:
			print("Player died!")
			#self.visible = false
			$Animation.self_modulate.a = 0.5
			dead = true
			invuln = false
			get_parent().get_parent().get_parent().emit_signal("checkGameOver")
			if Globals.inLevel:
				await get_tree().create_timer(3.0).timeout
				emit_signal("revive", self)
		else:
			invuln = true
			await get_tree().create_timer(1.0).timeout
			#print("invuln over")
			invuln = false

func _onRevive(who):
	who.get_node("Animation").self_modulate.a = 1
	who.health = 27
	get_parent().get_parent().get_parent().get_node("HealthManager").emit_signal("reviveUI", self.name)
	#reset ui Indicator
	who.dead = false

func _onRelocate(nearestPoint):
	# Disable collisions, change flags for relocation
	#self.get_node("CollisionShape2D").call_deferred("set", "disabled", true)
	velocity = Vector2(0, 0)
	relocating = true
	invuln = true
	get_node("CollisionShape2D").call_deferred("set", "disabled", true)
	reachedCheckpoint = false
	#var newVelocity = Vector2((nearestPoint.position - self.position) * (SPEED / 10 * get_process_delta_time()))
	await get_tree().create_timer(0.0001).timeout
	# Set destination, begin move to point
	checkpoint = nearestPoint
	velocity = Vector2(0,0)
	position = nearestPoint.position
	print("Position now: ", position)
	#velocity = newVelocity


func _onAnimationFinished():
	#print("Finished, ", $Animation.animation)
	if $Animation.animation == "Jump":
		jumpInProgress = false
	elif $Animation.animation == "Punch":
		punchInProgress = false
	pass


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var other = area.get_parent()
	if other.is_in_group("actionIndicators"):
		Globals.screenFlashEffect()
		print("my position")
		print(position.x)
		print("their position")
		print(other.position.x)
		scored.emit(self.name, abs(other.position.x - position.x))


func _on_attack_timer_timeout() -> void:
	canAttack = true
	attack.visible = false
	attack.monitoring = false
