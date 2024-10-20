extends Node2D

# Customizable time to complete a full cycle
@export var cycle_time: float = 2.0

# Variables to store random time offset and accumulated time
var time_offset: float
var accumulated_time: float = 0.0

func _ready():
	$AnimatedSprite2D.frame = randi() % 7
	
	# Set a random time offset to desync instances
	time_offset = randf() * cycle_time

func _process(delta):
	# Accumulate time and add random offset
	accumulated_time += delta
	var time = fposmod(accumulated_time + time_offset, cycle_time)
	
	# Normalize time to a value between 0 and 1
	var normalized_time = time / cycle_time
	
	# Calculate sinusoidal opacity ranging between 0 and 0.5
	var opacity = 0.25 + 0.25 * sin(normalized_time * TAU) # TAU is 2*PI
	
	# Apply the opacity to the sprite's modulate color
	$AnimatedSprite2D.modulate.a = opacity
