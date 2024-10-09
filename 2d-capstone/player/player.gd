extends CharacterBody2D

signal takeDamage(amount)
signal revive(who)
signal relocate(nearestPoint)
signal scored(id, score)

var curSprite
var JUMP_VELOCITY = -550.0
var SPEED = 150.0
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
var slide
var reachedCheckpoint = true
var relocating = false
var checkpoint
var editing = false
var index = 0
var hitBounds = false
var inZipline = false
var onTop = false
var originalPos

var jumpInProgress = false
var punchInProgress = false
var runInProgress = false
var punchConnected = false

# Other nodes
var otherPlayer
var worldNode
var sfxPlayer

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
		slide = "slide1"
		otherPlayer = "Player2"
	elif self.name == "Player2":
		left = "left2"
		right = "right2"
		jump = "jump2"
		punch = "punch2"
		slide = "slide2"
		otherPlayer = "Player1"

	attack = get_node("AttackHitbox")

	self.takeDamage.connect(_onTakeDamage)
	self.revive.connect(_onRevive)
	self.relocate.connect(_onRelocate)
	$Animation.animation_finished.connect(_onAnimationFinished)
	$Animation.play("Run")
	worldNode = get_tree().get_root().get_node("level")
	self.scored.connect(worldNode._onScored)
	
	sfxPlayer = $sfxPlayer

func _physics_process(delta: float) -> void:
	if not editing:
		if not relocating:
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta * 2

			#velocity.x = SPEED

			# If not currently in a song, allow regular movement, otherwise begin autoscroll
			if Globals.inLevel:
				# velocity.x = Globals.pixelsPerFrame
				# Pseudo-autoscroll prototype
				var direction = Input.get_axis(left, right)
				if not hitBounds and direction > 0:
					velocity.x =  Globals.pixelsPerFrame + SPEED
				elif hitBounds and direction > 0:
					velocity.x = Globals.pixelsPerFrame
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)
			else:
				pass 

			if Input.is_action_just_pressed(jump) and is_on_floor():
				$Animation.play("Jump")
				jumpInProgress = true
				velocity.y = JUMP_VELOCITY
				#await get_tree().create_timer(0.2).timeout

			if Input.is_action_just_pressed(slide):
				print("Sliding")
				get_node("Hitbox").scale *= Vector2(0.2, 0.2);
				$Animation.play("Slide");
				#get_node("Floor").disabled = false
				
			if Input.is_action_just_released(slide):
				print("Release sliding")
				get_node("Hitbox").scale *= Vector2(5, 5);
				$Animation.play("Run");
				#get_node("Floor").disabled = true
			
		if Input.is_action_just_pressed(punch):
			if inZipline and self.name == "Player1":
				var playerTouch = get_parent().get_node(otherPlayer)
				playerTouch.onTop = not playerTouch.onTop
				if (playerTouch.onTop):
					playerTouch.position.y = get_node("bottomMark").global_position.y
				else:
					playerTouch.position.y = get_node("topMark").global_position.y
			elif canAttack:
				# Artistic
				$Animation.play("Punch")
				sfxPlayer.play()
				# Technical
				punchInProgress = true
				attack.monitoring = true
				canAttack = false
				$attackTimer.start()
				punchConnected = false
		elif reachedCheckpoint:
			# Wait to respawn relocating player when teammate has aligned
			if get_parent().get_node(otherPlayer).position.x >= self.position.x:
				emit_signal("revive", self)
				# Reset relocating player position and allow control
				get_node("Hitbox").call_deferred("set", "disabled", false)
				relocating = false
				reachedCheckpoint = false
				invuln = false
				self.position.x = get_parent().get_node(otherPlayer).position.x
		move_and_slide()
	else:
		invuln = true

func _onTakeDamage(amount):
	$damagePlayer.play()
	if !dead or amount >= 10 or !invuln:		# amount over 10(or some num) means insta-death regardless of invuln
		health -= amount
		#print("Got hit! Health now: ", self.health)
		if health % 9 == 0:
			get_parent().get_parent().get_parent().get_node("HealthManager").emit_signal("decreaseHealth", self.name)
		if health <= 0:
			#print("Player died!")
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
	if nearestPoint != null:
		velocity = Vector2(0, 0)
		relocating = true
		invuln = true
		get_node("Hitbox").call_deferred("set", "disabled", true)
		reachedCheckpoint = false
		# Set destination, begin move to point
		checkpoint = nearestPoint
		position = nearestPoint.position

func _onAnimationFinished():
	#print("Finished, ", $Animation.animation)
	if $Animation.animation == "Jump":
		$Animation.play("Run")
	elif $Animation.animation == "Punch":
		$Animation.play("Run")
	pass


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var other = area.get_parent()
	if other.is_in_group("actionIndicators") and other.active and !punchConnected:
		punchConnected = true
		Globals.screenFlashEffect()
		other.active = false
		other.FadeOut()
		scored.emit(self.name, abs(other.position.x - position.x))


func _on_attack_timer_timeout() -> void:
	canAttack = true
	attack.monitoring = false
