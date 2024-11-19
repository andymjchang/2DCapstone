extends CharacterBody2D

signal takeDamage(amount)
signal revive(who)
signal relocate(nearestPoint)
signal scored(id, score)
signal getPowerup(powerType)
signal activatePowerup()
signal doubleJump()
signal getCoin()
signal skipping()
signal notSkipping()

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
var exitedZip = false
var onTop = false
var originalPos
var curPowerup

var jumpInProgress = false
var runInProgress = false
var punchConnected = false
var isSkipping

# Jump Hang Time
var hang_time_duration := 0.05
var hang_time_remaining := 0.0 
var is_hanging := false   

# Other nodes
var otherPlayer
var worldNode
var sfxPlayer
var camera
var coins = 0

var slideFriction = 0.999
var isSliding = false

#soundEffects
@onready var punchSfx = preload("res://audioEffects/Punch.mp3") as AudioStream
@onready var healthSfx = preload("res://audioEffects/SFX_HealthItem.mp3") as AudioStream
@onready var coinGrabSfx = preload("res://audioEffects/SFX_CoinCollect_1.mp3") as AudioStream
@onready var itemGrabSfX = preload("res://audioEffects/SFX_ItemGrab.mp3") as AudioStream

@onready var hitEffect : AnimatedSprite2D = $HitEffect
@onready var tweenSlide : Tween
@onready var tweenHit : Tween

# Camera Shake
var shake_strength = 25.0
var shake_decay = 5.0
var shake_intensity = 0.0

func _ready():
	# Reset shader parameters
	$Animation.material.set_shader_parameter("damage_intensity", 0.0)
	$Animation.material.set_shader_parameter("invulnerable_intensity", 0.0)
	
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
	self.doubleJump.connect(_onDoubleJump)
	self.getCoin.connect(_onGetCoin)
	self.skipping.connect(_onSkipping)
	self.notSkipping.connect(_onNotSkipping)
	$Animation.animation_finished.connect(_onAnimationFinished)
	$Animation.play("Run")
	worldNode = get_tree().get_root().get_node("level")
	self.scored.connect(worldNode._onScored)
	
	sfxPlayer = $sfxPlayer

	curPowerup = null
	
	# Attach to glitch line
	camera = worldNode.get_node("Camera2D")
	camera.global_position = self.global_position + Vector2(250, -70)
	var background = worldNode.get_node("Background")
	background.global_position = camera.global_position

func _physics_process(delta: float) -> void:
	if shake_intensity > 0:
		shake_intensity = lerpf(shake_intensity, 0, shake_decay * delta)
		camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		camera.offset = Vector2.ZERO
		
	if not editing and not isSkipping:
		if not inZipline:
			# Lines
			if is_on_floor():
				if exitedZip:
					$Animation.play("Run")
					exitedZip = false
				hang_time_remaining = 0.0
				is_hanging = false
				camera.smooth_pan_to(self.global_position.y + -50)
				Globals.resetCamera = false
				jumpInProgress = false
			
			# Add the gravity.
			if not is_on_floor():
				# Check if we're at the peak of our jump (very low upward velocity)
				if abs(velocity.y) < 30 and velocity.y < 0 and not is_hanging:
					is_hanging = true
					hang_time_remaining = hang_time_duration
				
				# Apply hang time logic
				if is_hanging and hang_time_remaining > 0:
					hang_time_remaining -= delta
					velocity.y = 0  # Keep vertical velocity at 0 during hang time
				else:
					is_hanging = false
					velocity += get_gravity() * delta * 2
					#$Animation.play("Jump")

			#velocity.x = SPEED

			# If not currently in a song, allow regular movement, otherwise begin autoscroll
			if Globals.inLevel:
				# Remove input check and always move forward at base speed plus scroll speed
				velocity.x = Globals.pixelsPerFrame + (SPEED * Globals.scrollSpeed) * Globals.scrollSpeed
				if hitBounds:
					velocity.x = Globals.pixelsPerFrame * Globals.scrollSpeed

			#debug this
			#if Input.is_action_pressed(slide):
				#velocity.x *= slideFriction

			if Input.is_action_just_pressed(jump) and is_on_floor():
				$Animation.play("Jump")
				velocity.y = JUMP_VELOCITY

			if Input.is_action_just_released(jump) and not jumpInProgress:
				if velocity.y < 0:
					velocity += get_gravity() * delta * 10

			if Input.is_action_just_pressed(slide):
				get_node("Hitbox").scale *= Vector2(1, 0.5)
				get_node("Hitbox").position.y = 6
				$Animation.play("Slide")
				#TODO get rid of double var
				isSliding = true
				#get_node("Floor").disabled = false
				SlideTweenStart()
				
			if Input.is_action_just_released(slide):
				get_node("Hitbox").scale *= Vector2(1, 2)
				get_node("Hitbox").position.y = 2
				isSliding = false
				$Animation.play("Run")
				#get_node("Floor").disabled = true
				SlideTweenEnd()

		elif inZipline and Input.is_action_pressed(jump):
			$Animation.play("Zip")
		
		elif inZipline and Input.is_action_just_released(jump):
			inZipline = false
			exitedZip = true
			$Animation.play("Fall")
			
		if Input.is_action_just_pressed(punch):
			if canAttack:
				# Animation
				if not inZipline:
					$Animation.play("Punch")
				else:
					$Animation.play("ZipPunch")
				$Animation.frame = 0 # Reset animation to 0 if already punching
				sfxPlayer.stream = punchSfx
				sfxPlayer.stream.loop = false
				sfxPlayer.play()

				# Technical
				attack.monitoring = true
				canAttack = false
				$attackLockoutTimer.start()
				$attackTimer.start()
				punchConnected = false
		
		#if Input.is_action_just_pressed("activate"):
			#emit_signal("activatePowerup")

		elif reachedCheckpoint:
			pass
		move_and_slide()
		if global_position.x > camera.global_position.x - 250:
			global_position.x = camera.global_position.x - 244
	else:
		invuln = true
		
	# Monitor Attack Hitbox Collisions
	if attack.monitoring:
		var overlappingAreas = attack.get_overlapping_areas()
		for area in overlappingAreas:
			MonitorAttackHitbox(area)

func _onTakeDamage(amount):
	$damagePlayer.play()
	shake_camera() # Add camera shake when taking damage
	
	# Glitch Shader
	$Animation.material.set_shader_parameter("damage_intensity", 0.5)
	$damagedTimer.start()
	
	if !invuln:
		if !dead or amount >= 10:		# amount over 10(or some num) means insta-death regardless of invuln
			if amount == 10:
				amount = health
			health -= amount
			if health % 9 == 0:
				get_parent().get_parent().get_parent().get_node("HealthManager").emit_signal("decreaseHealth", self.name)
			if health <= 0:
				# Reset shader parameters on death
				$Animation.material.set_shader_parameter("damage_intensity", 0.0)
				$Animation.material.set_shader_parameter("invulnerable_intensity", 0.0)
				$Animation.self_modulate.a = 0.5
				dead = true
				invuln = false
				get_parent().get_parent().get_parent().emit_signal("checkGameOver")
				if Globals.inLevel:
					await get_tree().create_timer(3.0).timeout
					emit_signal("revive", self)

func _onRevive(who):
	who.get_node("Animation").self_modulate.a = 1
	# Ensure shader parameters are reset on revive
	who.get_node("Animation").material.set_shader_parameter("damage_intensity", 0.0)
	who.get_node("Animation").material.set_shader_parameter("invulnerable_intensity", 0.0)
	who.health = 27
	get_parent().get_parent().get_parent().get_node("HealthManager").emit_signal("reviveUI", self.name)
	who.dead = false # reset ui Indicator

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

func MonitorAttackHitbox(area : Area2D):
	var other = area.get_parent()
	if other.is_in_group("actionIndicators") and other.active and !punchConnected:
		var otherParent = other.get_parent()
		other.active = false
		if otherParent.is_in_group("enemies") and otherParent.enemyType == "enemy":
			otherParent.GotHit()
			# Play hit animation
			hitEffect.frame = 0
			hitEffect.play()
		ResetAttack()
		PunchTween() # Camera
		punchConnected = true
		Globals.screenFlashEffect()
		other.FadeOut()
		scored.emit(self.name, 100 - abs(other.global_position.x - global_position.x))
		

func ResetAttack():
	canAttack = true
	attack.monitoring = false

# Powerup code
# TODO: Swap from string to enum
func _onGetPowerup(powerType):
	if curPowerup == null:
		sfxPlayer.stream = itemGrabSfX
		#sfxPlayer.stream.loop = false
		sfxPlayer.play()
		curPowerup = powerType
		print("I got: ", curPowerup)
		var particleEffect = get_node("CPUParticles2D")
		print("Loading: ", "res://particles/powerups/" + str(powerType) + ".png")
		particleEffect.texture = load("res://particles/powerups/" + str(powerType) + ".png")
		emit_signal("activatePowerup")
		#var powerSprite = get_node("Powerup")
		#powerSprite.frame = powerType
		#powerSprite.visible = true
		particleEffect.emitting = true
		particleEffect.visible = true

func _onActivatePowerup():
	match curPowerup:
		Globals.powerType.INVULN:
			invuln = true
			$Animation.material.set_shader_parameter("invulnerable_intensity", 0.5)
		Globals.powerType.HEAL:
			sfxPlayer.stream = healthSfx
			sfxPlayer.stream.loop = false
			sfxPlayer.play()
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
	#var powerSprite = get_node("Powerup")
	#powerSprite.visible = false
	$powerupTimer.start()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().enemyType == "slideEnemy" and isSliding: #Globals.isSliding:
		#we slid into enemy
		print("made it into slide damage: ")
		var other = area.get_parent()
		scored.emit(self.name, abs(other.global_position.x - global_position.x))
		other = other.get_parent()
		print("made it into slide damage: 1")
		if other.is_in_group("enemies"):
			print("made it into slide damage: 2")
			other.GotHit()
				# Play hit animation
			hitEffect.frame = 0
			hitEffect.play()
	elif area.get_parent().ifDead == false :
		scored.emit(self.name, -100)
		_onTakeDamage(3)


func _on_damaged_timer_timeout() -> void:
	$Animation.material.set_shader_parameter("damage_intensity", 0.0)


func _onPowerupTimerTimeout() -> void:
	print("Timeout!")
	match curPowerup:
		Globals.powerType.INVULN:
			invuln = false
			$Animation.self_modulate.a = 1
			$Animation.material.set_shader_parameter("invulnerable_intensity", 0.0)
		Globals.powerType.HEAL:
			pass
		Globals.powerType.SPEEDUP:
			worldNode.emit_signal("changeSpeed", 0)
		Globals.powerType.SLOWDOWN:
			worldNode.emit_signal("changeSpeed", 0)
	curPowerup = null

func _onVisibleOnScreenNotifier2dScreenExited() -> void:
	print("Left camera")
	#Globals.resetCamera = true
	pass # Replace with function body.

func _onDoubleJump():
	$Animation.play("Jump")
	jumpInProgress = true
	velocity.y = JUMP_VELOCITY * 2.4

func _onGetCoin():
	print("Coin get")
	sfxPlayer.stream = coinGrabSfx
	sfxPlayer.stream.loop = false
	sfxPlayer.play()
	self.coins += 1
	Globals.coinsCollected = self.coins

func SlideTweenStart():
	if tweenHit != null:
		tweenHit.kill()
	tweenHit = create_tween()
	tweenHit.tween_property(camera, "rotation", 0.008363323, 0.15)
	tweenHit.parallel().tween_property(camera, "zoom", Vector2(2.2, 2.2), 0.15)

func SlideTweenEnd():
	if tweenHit != null:
		tweenHit.kill()
	tweenHit = create_tween()
	tweenHit.tween_property(camera, "rotation", 0, 0.15)
	tweenHit.parallel().tween_property(camera, "zoom", Vector2(2.0, 2.0), 0.15)

func PunchTween():
	camera.zoom = camera.zoom + Vector2(0.025, 0.025)
	if camera.zoom.x > 2.15 or camera.zoom.y > 2.15:
		camera.zoom = Vector2(2.15, 2.15)
	camera.rotation = max(camera.rotation - 0.01363323, -0.02831615)
	if tweenHit != null:
		tweenHit.kill()
	tweenHit = create_tween()
	# Add delay chain before the actual tweens
	tweenHit.tween_interval(0.1)
	tweenHit.tween_property(camera, "rotation", 0, 0.15)
	tweenHit.parallel().tween_property(camera, "zoom", Vector2(2.0, 2.0), 1.0)

# Add this new function
func shake_camera(strength: float = 25.0):
	shake_intensity = strength * Globals.screenShakeIntensity

func _on_attack_timer_timeout() -> void:
	attack.monitoring = false

func _on_attack_lockout_timer_timeout() -> void:
	canAttack = true

func _onSkipping() -> void:
	isSkipping = true

func _onNotSkipping() -> void:
	isSkipping = false
