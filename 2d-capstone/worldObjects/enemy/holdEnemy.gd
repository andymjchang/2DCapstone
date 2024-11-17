extends Node2D

@onready var headSprite = $SlideEnemyHead
@onready var bodySprites = $Segments
@onready var tailSprite = $SlideEnemyEnd
@onready var bodySprite = $Segments/SlideEnemyMiddle

var squash_speed: float = 20.0  # Adjust this value to control squashing speed
var is_squashing: bool = false
var original_width: float
var original_distance: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tail_pos = tailSprite.position
	var head_pos = headSprite.position
	original_distance = abs(head_pos.x - tail_pos.x)
	
	# Calculate number of body segments needed
	var segment_width = 300
	var num_segments = ceil(original_distance / segment_width)
	print("num_segments: ", num_segments)
	# Create and position body segments
	for i in range(num_segments):
		var new_segment = bodySprite.duplicate()
		bodySprites.add_child(new_segment)
		new_segment.position.x = (i * segment_width) - (original_distance / 2)
		new_segment.visible = true

	bodySprites.position.x = (head_pos.x + tail_pos.x) / 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_squashing:
		var tail_pos = tailSprite.position
		var head_pos = headSprite.position
		headSprite.position.x += squash_speed * delta
		
		var distance = abs(head_pos.x - tail_pos.x)
		
		if distance <= headSprite.get_node("Head").texture.get_width() / 4:
			is_squashing = false
			return
			
		headSprite.position.x += squash_speed * delta
		
		# Update body segments scale and position
		var scale_factor = distance / original_distance
		bodySprites.scale.x = scale_factor
		
		# Update position of body segments container
		bodySprites.position.x = (head_pos.x + tail_pos.x) / 2.0

func start_squash():
	is_squashing = true
	original_distance = abs(headSprite.position.x - tailSprite.position.x)
