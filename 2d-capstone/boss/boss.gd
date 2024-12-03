extends Node2D

var time: float = 0.0
var initial_y: float
var amplitude: float = 30.0  # How far up/down the boss moves
var speed: float = 1.5      # How fast the boss moves
var random_offset: float = 0.0
var random_timer: float = 0.0

@export var sprite : AnimatedSprite2D
@export var glitch : ColorRect

func _ready() -> void:
	initial_y = $Sprite.position.y
	
	glitch.modulate.a = 1.0
	sprite.modulate.a = 0.0
	
	# fade out glitch and reduce shake
	var glitch_tween = create_tween()
	glitch_tween.set_parallel(true)  # Allow multiple properties to tween simultaneously
	glitch_tween.tween_property(glitch, "modulate:a", 0.0, 5.0)
	glitch_tween.tween_property(glitch.material, "shader_parameter/shake_rate", 0.0, 5.0)
	
	# fade in sprite
	var sprite_tween = create_tween()
	sprite_tween.tween_property(sprite, "modulate:a", 1.0, 5.0)

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
	sprite.position.y = new_y
