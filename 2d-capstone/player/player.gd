extends CharacterBody2D

signal takeDamage(amount)
signal revive(who)
signal relocate(nearestPoint)
signal scored(id, score)
signal getPowerup(powerType)
signal activatePowerup()

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
var curPowerup

var jumpInProgress = false
var punchInProgress = false
var runInProgress = false
var punchConnected = false

# Other nodes
var otherPlayer
var worldNode
var sfxPlayer
var glitchLines
var camera

@onready var hitEffect : AnimatedSprite2D = $HitEffect
@onready var tweenRot : Tween
@onready var tweenZoom : Tween

func _ready():
	curSprite = get_node("Animation").duplicate()
	add_to_group("players")
	# Controls for player
	left = "leftPlayer"
	right = "rightPlayer"
	jump = "jump"
	punch = "punch"
	slide = "slide"

	attack = get_node("AttackHitbox")

	self.takeDamage.connect(_onTakeDamage)
	self.getPowerup.connect(_onGetPowerup)
	self.activatePowerup.connect(_onActivatePowerup)
	self.revive.connect(_onRevive)
	self.relocate.connect(_onRelocate)
	$Animation.animation_finished.connect(_onAnimationFinished)
	$Animation.play("Run")
	worldNode = get_tree().get_root().get_node("level")
	self.scored.connect(worldNode._onScored)
	
	sfxPlayer = $sfxPlayer

	curPowerup = null
	
	# Attach to glitch line
	camera = worldNode.get_node("Camera2D")
	glitchLines = camera.get_node("glitchLines")
	camera.global_position = self.global_position + Vector2(250, -70)
	var background = worldNode.get_node("Background")
	background.global_position = camera.global_position

func _physics_process(delta: float) -> void:
	if not editing:
		if not inZipline:
			# Lines
			if is_on_floor():
				glitchLines.global_position.y = self.global_position.y
			
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
					velocity.x =  Globals.pixelsPerFrame + (SPEED * Globals.scrollSpeed) * Globals.scrollSpeed
				elif hitBounds and direction > 0:
					velocity.x = Globals.pixelsPerFrame * Globals.scrollSpeed
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)

			if Input.is_action_just_pressed(jump) and is_on_floor():
				$Animation.play("Jump")
				jumpInProgress = true
				velocity.y = JUMP_VELOCITY

			if Input.is_action_just_pressed(slide):
				get_node("Hitbox").scale *= Vector2(1, 0.5);
				get_node("Hitbox").position.y = 6
				$Animation.play("Slide");
				#get_node("Floor").disabled = false
				var rotDir = Globals.get_random_sign()
				tweenRot = create_tween()
				tweenZoom = create_tween()
				tweenRot.tween_property(camera, "rotation", 0.004363323 * rotDir, 0.2)
				tweenZoom.tween_property(camera, "zoom", Vector2(2.1, 2.1), 0.5)
				#camera.zoom = Vector2(2.2, 2.2)
				
			if Input.is_action_just_released(slide):
				get_node("Hitbox").scale *= Vector2(1, 2);
				get_node("Hitbox").position.y = 2
				$Animation.play("Run");
				#get_node("Floor").disabled = true
				tweenRot = create_tween()
				tweenZoom = create_tween()
				tweenRot.tween_property(camera, "rotation", 0, 0.2)
				tweenZoom.tween_property(camera, "zoom", Vector2(2.0, 2.0), 0.5)
			
		if Input.is_action_just_pressed(punch):
			if canAttack:
				# Artistic
				$Animation.play("Punch")
				sfxPlayer.play()
				# Technical
				print("punch is now true!, ", Globals.time)
				punchInProgress = true
				attack.monitoring = true
				attack.monitoring = true
				canAttack = false
				$attackTimer.start()
				punchConnected = false
		
		if Input.is_action_just_pressed("activate"):
			emit_signal("activatePowerup")

		elif reachedCheckpoint:
			pass
		move_and_slide()
	else:
		invuln = true

func _onTakeDamage(amount):
	$damagePlayer.play()
	
	# Glitch Shader
	$GlitchShader.visible = true
	$damagedTimer.start()
	
	if !invuln:
		if !dead or amount >= 10:		# amount over 10(or some num) means insta-death regardless of invuln
			if amount == 10:
				amount = health
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
		_on_attack_timer_timeout() # reset attack timer
		punchConnected = true
		Globals.screenFlashEffect()
		other.active = false
		other.FadeOut()
		scored.emit(self.name, abs(other.global_position.x - global_position.x))
	if other.is_in_group("enemies"):
		other.GotHit()
		# Play hit animation
		hitEffect.frame = 0
		hitEffect.play()

func _on_attack_timer_timeout() -> void:
	canAttack = true
	attack.monitoring = false

# Powerup code
# TODO: Swap from string to enum
func _onGetPowerup(powerType):
	curPowerup = powerType
	worldNode.powerupUI.visual.frame = powerType
	worldNode.powerupUI.visual.show()
	print("I got: ", curPowerup)

func _onActivatePowerup():
	match curPowerup:
		Globals.powerType.INVULN:
			invuln = true
			$Animation.self_modulate.a = 0.5
		Globals.powerType.HEAL:
			var potentialHealth = health + 9
			if potentialHealth > 27:
				health = 27
			else:
				health += 9
			get_parent().get_parent().get_parent().get_node("HealthManager").emit_signal("increaseHealth", self.name)
		Globals.powerType.SPEEDUP:
			worldNode.emit_signal("changeSpeed", 1)
		Globals.powerType.SLOWDOWN:
			print("Slowing down")
			worldNode.emit_signal("changeSpeed", -1)
	worldNode.powerupUI.visual.hide()
	$powerupTimer.start()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().ifDead == false:
		_onTakeDamage(3)


func _on_damaged_timer_timeout() -> void:
	$GlitchShader.visible = false
func _onPowerupTimerTimeout() -> void:
	print("Timeout!")
	match curPowerup:
		Globals.powerType.INVULN:
			invuln = false
			$Animation.self_modulate.a = 1
		Globals.powerType.HEAL:
			pass
		Globals.powerType.SPEEDUP:
			worldNode.emit_signal("changeSpeed", 0)
		Globals.powerType.SLOWDOWN:
			worldNode.emit_signal("changeSpeed", 0)
	curPowerup = null
