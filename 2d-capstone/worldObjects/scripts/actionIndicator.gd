extends Node2D

@export var startingScale : float
@export var animation_time: float = 1.0
var target_time: float = 1.0
var elapsed_time: float = 0
var active: bool = false
var starting_scale
var blockType = "actionIndicator"
var curSprite
@onready var actionIndicatorManager
@onready var inner_circle = $innerCircle
@onready var outer_circle = $outerCircle
@onready var timer = $Timer
signal scored(indicator_position)

var index = 0

# Start with higher scale and 0 opacity
func _ready() -> void:
	actionIndicatorManager = get_parent()
	
	curSprite = get_node("innerCircle").duplicate()
	starting_scale = Vector2(startingScale, startingScale)
	outer_circle.scale = starting_scale
	outer_circle.modulate.a = 0.0 # Starting opacity (fully transparent)
	
	# decide target_time based on world position
	var time = position.x / Globals.pixelsPerFrame
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
	outer_circle.scale = starting_scale.lerp(Vector2(1.0, 1.0), t)
	
	# Lerp the opacity from 0 to 1
	var current_modulate = outer_circle.modulate
	current_modulate.a = lerp(0.0, 1.0, t)
	outer_circle.modulate = current_modulate
	
	# Stop the transition if the time has been reached
	if t >= 1.0:
		outer_circle.visible = true
		scored.emit(position.x)
		Globals.screenFlashEffect()
		queue_free()


#func _on_timer_timeout() -> void:
	#queue_free()
	#
#func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if event.is_action_pressed("click"):
		#print("click")
		#get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType)
	#pass # Replace with function body.
