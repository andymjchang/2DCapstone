extends Node2D

var count = 0
var ifDead = false
var secondTime = false
var blockType = "enemy"

# Death animation
var velocity = Vector2(0, 0)
var move_speed = 600
var gravity = 2000
var min_rotation = -45 * (PI / 180)
var max_rotation = 45 * (PI / 180)

var soundPlayer := AudioStreamPlayer.new()
@onready var sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check for platform below
	var has_platform_below = check_platform_below()
	
	# Set up sprites
	sprite = $AnimatedSprite2D
	var flying_sprite = $FlyingAnimatedSprite2D
	
	if has_platform_below:
		sprite.visible = true
		flying_sprite.visible = false
	else:
		sprite.visible = false
		flying_sprite.visible = true
	
	# vary animation
	var active_sprite = sprite if has_platform_below else flying_sprite
	active_sprite.speed_scale = randf_range(0.8, 1.2)
	active_sprite.frame = randi() % 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ifDead:
		#sprite.position.y += 4
		#sprite.rotation = 0.8
		DeathAnimation(delta)
# Ensure that this func can be run after the hit detection on the same frame
func DeathAnimation(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = move_speed
	position += velocity * delta


	
	
	
func GotHit():
	self.ifDead = true
	velocity.y = randi_range(-600, -300)
	sprite.rotation = randf_range(min_rotation, max_rotation)
	get_parent().get_parent().get_parent().get_node("ScoreBar/TextureProgressBar").emit_signal("increaseScore")

func check_platform_below() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 50))
	query.collision_mask = 0b1  # Platform is on layer 1
	var result = space_state.intersect_ray(query)
	return result and result.collider.is_in_group("blocks")