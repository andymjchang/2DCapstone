extends Node2D

var count = 0
var ifDead = false
var secondTime = false
var blockType = "enemy"
var enemyType = "enemy"

@onready var enemyImage = preload("res://worldObjects/assets/singleBot.png") as Texture2D
@onready var slideEnemyImage = preload("res://worldObjects/assets/slideEnemy.png") as Texture2D

# Death animation
var velocity = Vector2(0, 0)
var move_speed = 600
var gravity = 2000
var min_rotation = 15 * (PI / 180)
var max_rotation = 45 * (PI / 180)
var death_timer = 0.0
var initial_scale = Vector2(1, 1)
var current_scale = Vector2(1, 1)

var soundPlayer := AudioStreamPlayer.new()
@onready var sprite
@onready var animatedSprite = $AnimatedSprite2D
var activeSprite

# Replace punch variables with timer variables
var isFirstHit = false
var activeTime = 2.0  # Time in seconds the enemy stays active
var timeRemaining = 0.0

# Add rotation direction variable
var rotationDirection = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Set up sprites
	sprite = $AnimatedSprite2D
	var flying_sprite = $FlyingAnimatedSprite2D

	sprite.visible = true
	flying_sprite.visible = false
	
	# vary animation
	activeSprite = sprite
	activeSprite.speed_scale = randf_range(0.8, 1.2)
	activeSprite.frame = randi() % 4

	# Replace punch variables with timer variables
	timeRemaining = activeTime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if ifDead:	
		DeathAnimation(delta)
	elif isFirstHit:
		# Count down timer and move
		timeRemaining -= delta
		position.x += Globals.pixelsPerFrame * delta * Globals.scrollSpeed
		
		# Kill enemy when time runs out
		if timeRemaining <= 0:
			Die()

# Ensure that this func can be run after the hit detection on the same frame
func DeathAnimation(delta: float) -> void:
	death_timer += delta
	
	# Handle velocity
	velocity.y += gravity * delta
	if death_timer > 0.25:  # Start slowing down after 0.3 seconds
		velocity.x = move_toward(velocity.x, 0, move_speed * delta)
	else:
		velocity.x = move_speed
	position += velocity * delta
	
	# Handle rotation
	if death_timer > 0.25:  # Start rotating back to 0 after 0.3 seconds
		activeSprite.rotation = move_toward(activeSprite.rotation, -1, 2 * delta)
	
	# Handle scale
	if death_timer < 0.1:  # Initial scale increase
		current_scale = initial_scale * 1.35
	else:  # Scale back to normal
		current_scale = current_scale.move_toward(initial_scale, delta)
	activeSprite.scale = current_scale
	if death_timer > 2.0:
		queue_free()
func GotHit():
	$ActionIndicator.active = true
	$ActionIndicator.doNotFadeOut = true
	activeSprite.rotation = randf_range(min_rotation, max_rotation) * rotationDirection
	rotationDirection *= -1
	if !isFirstHit:
		# First hit behavior - activate the enemy
		isFirstHit = true
		timeRemaining = activeTime
		activeSprite.modulate = Color(1.0, 0.5, 0.5)  # Visual feedback

# New helper function for death logic
func Die():
	$ActionIndicator.doNotFadeOut = false
	$ActionIndicator.active = false
	$ActionIndicator.FadeOut()
	self.ifDead = true
	velocity.y = randi_range(-600, -500)
	activeSprite.rotation = randf_range(min_rotation, max_rotation)
	death_timer = 0.0
	initial_scale = activeSprite.scale
	current_scale = initial_scale
	activeSprite.isPulseActive = false

func setEnemyType(posPoints) -> void :
	
	if posPoints.size() > 2:
		var newType = posPoints[2]
		match newType:
			"enemy":
					animatedSprite.animation = "default"
					enemyType = "enemy"
					var newYExtents = (enemyImage.get_size().y * animatedSprite.scale.y) / 2.0
					var newXExtents = (enemyImage.get_size().x * animatedSprite.scale.x) / 2.0
					$Area2D/CollisionShape2D.shape.extents = Vector2(newXExtents, newYExtents)
			"slideEnemy":
				#TODO make sure that the hiy boxes are not a shared resource
				animatedSprite.animation = "slideEnemy"
				enemyType = "slideEnemy"
				var newYExtents = (slideEnemyImage.get_size().y * animatedSprite.scale.y) / 2.0
				var newXExtents = (slideEnemyImage.get_size().x * animatedSprite.scale.x) / 2.0
				$Area2D/CollisionShape2D.shape.extents = Vector2(newXExtents, newYExtents)
		#set the collision based on it 
func check_platform_below() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 50))
	query.collision_mask = 0b1  # Platform is on layer 1
	var result = space_state.intersect_ray(query)
	return result and result.collider.is_in_group("blocks")
	
func setTime(posPoints):
	#ugh math
	var startX = posPoints[0]
	var endX = posPoints[2]
	
	print("start x: ", startX , " end x: ", endX)
	#have to caclulate the time from start to end
		#player1.global_position = Globals.checkpoint
		#get_node("Camera2D").moveCamera(player1.global_position.x)
		#var distance = abs(0.0 - player1.global_position.x)
		#var playerSpeed = player1.SPEED
		#musicTime = distance / Globals.pixelsPerFrame
		#Globals.time = 0.0
		#Globals.time += musicTime
	var distance = abs(endX - startX)
	activeTime = distance / Globals.pixelsPerFrame
	timeRemaining = 0.0
	print("setting time to: ", distance / Globals.pixelsPerFrame)
