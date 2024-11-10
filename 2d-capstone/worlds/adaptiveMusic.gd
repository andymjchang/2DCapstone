extends AudioStreamPlayer2D

var max_y_position: float = 500.0  # Position where audio is silent
var fade_distance: float = 1000.0   # Distance over which fading occurs

func _ready() -> void:
	volume_db = -80

func _process(_delta: float) -> void:
	var current_y = global_position.y
	
	# Calculate fade based on distance from max_y_position
	var distance_from_max = max_y_position - current_y
	var fade_factor = clamp(distance_from_max / fade_distance, 0.0, 1.0)
	
	# Convert to decibels (-80db is essentially silent)
	volume_db = lerp(-80.0, 0.0, fade_factor)
