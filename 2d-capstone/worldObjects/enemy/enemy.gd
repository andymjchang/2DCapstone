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

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("players"):
		#here if we want it lol, doesnt work as of now
		#var soundEffect = load("res://audioTracks/record-scratches-31350.mp3")
		#soundPlayer.stream = soundEffect
		#soundPlayer.play()
		#body.emit_signal("takeDamage",1)
		pass

	
	
	
func GotHit():
	self.ifDead = true
	velocity.y = randi_range(-600, -300)
	sprite.rotation = randf_range(min_rotation, max_rotation)
	get_parent().get_parent().get_parent().get_node("ScoreBar/TextureProgressBar").emit_signal("increaseScore")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("playerHitbox"):
		print("plaer hitbox")
		GotHit()

	pass # Replace with function body.
