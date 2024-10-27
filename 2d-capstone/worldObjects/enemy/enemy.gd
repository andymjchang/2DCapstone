extends Node2D
signal takeDamage

var count = 0
var ifDead = false
var secondTime = false
var blockType = "enemy"

var up
var down 
var left
var right
var index = 0

# Death animation
var velocity = Vector2(0, 0)
var move_speed = 600
var gravity = 2000
var min_rotation = -45 * (PI / 180)
var max_rotation = 45 * (PI / 180)

var soundPlayer := AudioStreamPlayer.new()
@onready var sprite

var isMultiPunch = false
var punchesLeft = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")
	add_child(soundPlayer)
	up = "up"
	down = "down"
	left = "left"
	right = "right"
	
	# vary animation
	sprite = $AnimatedSprite2D
	sprite.speed_scale = randf_range(0.8, 1.2)
	sprite.frame = randi() % 4
	
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
	if !isMultiPunch or punchesLeft == 0.0:
		self.ifDead = true
		velocity.y = randi_range(-600, -300)
		sprite.rotation = randf_range(min_rotation, max_rotation)
		#get_parent().get_parent().get_parent().get_node("ScoreBar/TextureProgressBar").emit_signal("increaseScore")
		get_tree().current_scene.get_node("ScoreBar/TextureProgressBar").emit_signal("increaseScore")
	else:
		punchesLeft-=1
		get_parent().moveToNext()
		#got to move self to next indictaor
		


	pass # Replace with function body.
