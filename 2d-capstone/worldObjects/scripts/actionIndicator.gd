extends Node2D

@export var startingScale : float
@export var animation_time: float = 1.0
@export var endColor : Color = Color(0.76, 0.23, 0.24, 1)
var startColor : Color = Color(1, 1, 1, 1)
var target_time: float = 1.0
var elapsed_time: float = 0
var active: bool = false
var starting_scale
var blockType = "actionIndicator"
var curSprite
var parent
var parentSprite
@onready var inner_circle = $innerCircle
@onready var outer_circle = $outerCircle

var index = 0

# Start with higher scale and 0 opacity
func initialize():
	parent = get_parent()
	if parent.is_in_group("enemies"):
		parentSprite = parent.get_node("AnimatedSprite2D")
	
	curSprite = get_node("innerCircle").duplicate()
	starting_scale = Vector2(startingScale, startingScale)
	outer_circle.scale = starting_scale
	outer_circle.modulate.a = 0.0 # Starting opacity (fully transparent)
	inner_circle.modulate.a = 0.0
	
	# decide target_time based on world position
	var time = global_position.x / Globals.pixelsPerFrame
	set_target_time(time)

# Set the time over which the transition occurs
func set_target_time(time: float) -> void:
	target_time = time
func get_target_time():
	return target_time - animation_time + 3.0

# Activate the transition
func start_transition():
	if active == false:
		elapsed_time = 0
		active = true

# Update the outer circle's scale and opacity each frame
func _process(delta: float) -> void:
	if !active:
		return
	
	# Increment the elapsed time
	elapsed_time += delta
	
	# Calculate the lerp factor based on the elapsed time and target time
	var t = clamp(elapsed_time / animation_time, 0.0, 1.0)
	
	# Lerp the scale from its current value to 1.0
	outer_circle.scale = starting_scale.lerp(Vector2(0.1, 0.1), t)
	
	# Lerp the opacity from 0 to 1
	var current_modulate = outer_circle.modulate
	current_modulate.a = lerp(0.0, 1.0, t)
	outer_circle.modulate = current_modulate
	inner_circle.modulate = current_modulate
	if parentSprite:
		parentSprite.modulate = lerp(startColor, endColor, t)
	
	# Stop the transition if the time has been reached
	if t >= 1.0:
		FadeOut()

func FadeOut():
	if parentSprite:
		var parentTween = create_tween()
		parentTween.tween_property(parentSprite, "modulate", startColor, 0.5)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)

func _on_death_timer_timeout() -> void:
	queue_free()
