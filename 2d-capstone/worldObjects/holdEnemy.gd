extends Node2D

@onready var headSprite = $SlideEnemyHead
@onready var bodySprites = $Segments
@onready var tailSprite = $SlideEnemyEnd

var squash_speed: float = 20.0  # Adjust this value to control squashing speed
var is_squashing: bool = false
var original_width: float
var original_distance: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tail_pos = tailSprite.position
	var head_pos = headSprite.position
	bodySprites.position.x = (head_pos.x + tail_pos.x) / 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_squash()
		print("squash")
	if is_squashing:
		# Move head towards tail
		var tail_pos = tailSprite.position
		var head_pos = headSprite.position
		headSprite.position.x += squash_speed * delta
		
		# Calculate the distance between head and tail
		var distance = abs(head_pos.x - tail_pos.x)
		
		# Stop squashing if head is very close to tail
		if distance <= headSprite.get_node("Head").texture.get_width() / 4:  # You can adjust this minimum distance
			is_squashing = false
			return
			
		headSprite.position.x += squash_speed * delta
		
		# Update body segments scale and position
		print(distance)
		bodySprites.scale.x = distance / original_distance
		bodySprites.position.x = (head_pos.x + tail_pos.x) / 2.0

func start_squash():
	is_squashing = true
	original_distance = abs(headSprite.position.x - tailSprite.position.x)
