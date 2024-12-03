extends Node2D

var time: float = 0.0
var initial_y: float
var amplitude: float = 30.0  # How far up/down the boss moves
var speed: float = 1.5      # How fast the boss moves
var random_offset: float = 0.0
var random_timer: float = 0.0

func _ready() -> void:
	initial_y = $Sprite.position.y
	
func _process(delta: float) -> void:
	time += delta
	random_timer += delta
	
	# Update random offset every 2 seconds
	if random_timer >= 2.0:
		random_timer = 0.0
		random_offset = randf_range(-10.0, 10.0)
	
	# Calculate new Y position using sine wave + random offset
	var new_y = initial_y + (sin(time * speed) * amplitude) + random_offset
	
	# Clamp the position to prevent moving too far
	new_y = clamp(new_y, initial_y - amplitude, initial_y + amplitude)
	
	# Update sprite position
	$Sprite.position.y = new_y
