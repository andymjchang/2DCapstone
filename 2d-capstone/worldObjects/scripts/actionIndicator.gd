extends Node2D

@export var startingScale : float
@export var animation_time: float = 1.0
@export var endColor : Color = Color(0.76, 0.23, 0.24, 1)
var startColor : Color = Color(1, 1, 1, 1)
var target_time: float = 1.0
var active: bool = false
var fadeOut : bool = false
var starting_scale
var blockType = "actionIndicator"
var curSprite
@onready var inner_circle = $innerCircle
@onready var outer_circle = $outerCircle
var index = 0

func initialize():
	print("Global time restart at here: ", Globals.time)
	curSprite = get_node("innerCircle").duplicate()
	starting_scale = Vector2(startingScale, startingScale)
	outer_circle.scale = starting_scale
	outer_circle.modulate.a = 0.0
	inner_circle.modulate.a = 0.0
	
	var time = global_position.x / Globals.pixelsPerFrame
	set_target_time(time)

func set_target_time(time: float) -> void:
	target_time = time

func get_target_time():
	return target_time - animation_time

func start_transition():
	if active == false:
		active = true

func _process(_delta: float) -> void:
	if !active:
		return
	
	# Calculate progress based on global time difference
	var time_remaining = target_time - Globals.time
	var progress = 1.0 - (time_remaining / animation_time)
	var t = clamp(progress, 0.0, 1.0)
	
	# Update visual elements based on time progress
	outer_circle.scale = starting_scale.lerp(Vector2(0.1, 0.1), t)
	
	var current_modulate = outer_circle.modulate
	current_modulate.a = lerp(0.0, 1.0, t)
	outer_circle.modulate = current_modulate
	inner_circle.modulate = current_modulate
	
	# Trigger fade out when animation completes
	if t >= 1.0:
		FadeOut()
		fadeOut = true

func FadeOut():
	if fadeOut:
		return
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)

func _on_death_timer_timeout() -> void:
	queue_free()
	#
func resetAnimation(newPos) -> void :
	#enemy has been pushed back, reset the action indicator
	target_time = newPos.x / Globals.pixelsPerFrame
	active = true 
	
	curSprite = get_node("innerCircle").duplicate()
	starting_scale = Vector2(startingScale, startingScale)
	outer_circle.scale = starting_scale
	outer_circle.modulate.a = 0.0
	inner_circle.modulate.a = 0.0
	outer_circle.texture = load("res://worldObjects/assets/circle.png")
	fadeOut = false
	get_tree().current_scene.get_node("objectList/actionIndicators").starting_index -= 1
	
