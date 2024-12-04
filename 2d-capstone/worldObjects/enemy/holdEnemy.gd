extends Node2D

@onready var headSprite = $SlideEnemyHead
@onready var bodySprites = $Segments
@onready var tailSprite = $SlideEnemyEnd
@onready var bodySprite = $Segments/SlideEnemyMiddle

var is_squashing: bool = false
var original_scale: float
var original_distance: float
var enemyType = "enemy"
# Death animation variables
var velocity = Vector2(0, 0)
var move_speed = 600
var gravity = 2000
var min_rotation = 15 * (PI / 180)
var max_rotation = 45 * (PI / 180)
var death_timer = 0.0
var initial_scale = Vector2(1, 1)
var current_scale = Vector2(1, 1)
var ifDead = false

# Timer variables
var isFirstHit = false
var activeTime = 2.0
var timeRemaining = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tail_pos = tailSprite.position
	var head_pos = headSprite.position
	original_distance = abs(head_pos.x - tail_pos.x)
	bodySprite.position.x = (head_pos.x + tail_pos.x) / 2.0
	
	# Calculate number of body segments needed
	var segment_width = 75.0 / 2
	var num_segments = max(1, floor(original_distance / segment_width))
	
	# Adjust segment width to evenly distribute across the space
	var adjusted_segment_width = original_distance / num_segments
	
	# Create and position body segments
	for i in range(num_segments):
		var new_segment = bodySprite.duplicate()
		bodySprites.add_child(new_segment)
		# Scale each segment to match the adjusted width
		new_segment.scale.x = 0.125 * adjusted_segment_width / segment_width
		new_segment.position.x = (i * adjusted_segment_width) - (original_distance / 2) + (new_segment.scale.x * bodySprite.get_texture().get_width() / 2)
		original_scale = new_segment.scale.x
		new_segment.visible = true
		new_segment.flip_h = (true if i % 2 == 0 else false)

	bodySprites.position.x = (head_pos.x + tail_pos.x) / 2.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ifDead:
		DeathAnimation(delta)
	elif isFirstHit:
		# Count down timer
		timeRemaining -= delta
		
		# Handle squashing
		if is_squashing:
			var tail_pos = tailSprite.position
			var head_pos = headSprite.position
			headSprite.position.x += Globals.pixelsPerFrame * delta * Globals.scrollSpeed
			
			var distance = abs(head_pos.x - tail_pos.x)
			
			if !Input.is_action_pressed("punch") or distance <= 10:
				Die()
				return
			# Update body segments
			var scale_factor = distance / original_distance
			bodySprites.scale.x = scale_factor
			bodySprites.position.x = (head_pos.x + tail_pos.x) / 2.0


func start_squash():
	is_squashing = true
	original_distance = abs(headSprite.position.x - tailSprite.position.x)

func DeathAnimation(delta: float) -> void:
	death_timer += delta
	
	# Handle velocity
	velocity.y += gravity * delta
	if death_timer > 0.25:
		velocity.x = move_toward(velocity.x, 0, move_speed * delta)
	else:
		velocity.x = move_speed
	position += velocity * delta
	
	# Handle rotation
	if death_timer > 0.25:
		rotation = move_toward(rotation, -1, 2 * delta)
	
	# Handle scale
	if death_timer < 0.1:
		current_scale = initial_scale * 1.35
	else:
		current_scale = current_scale.move_toward(initial_scale, delta)
	scale = current_scale
	if death_timer > 2.0:
		queue_free()

func GotHit():
	if !isFirstHit:
		isFirstHit = true
		timeRemaining = activeTime
		start_squash()

func Die():
	queue_free()
	self.ifDead = true
	is_squashing = false
	velocity.y = randi_range(-600, -500)
	rotation = randf_range(min_rotation, max_rotation)
	death_timer = 0.0
	initial_scale = scale
	current_scale = initial_scale

func setTime(posPoints):
	pass

func setEnemyType(posPoints) -> void :
	enemyType = "enemy"