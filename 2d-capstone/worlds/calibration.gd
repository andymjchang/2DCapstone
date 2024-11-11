extends Node2D

@export var drawMarker : bool = true

@onready var delayLabel : Label = $Label
@onready var averageDelayLabel : Label = $Label2
var bpm = 115.0
var beat_interval : float
var next_beat_time : float
var audio_player : AudioStreamPlayer2D

# Add new variables for visualization
var circle_center = Vector2(200, 200)  # Position of circle center
var circle_radius = 792 / 2
var timing_points = []  # Store recent timing points
var timing_differences = []  # Add this with other variables at the top
var average_delay : float = 0.0

var current_time : float = 0.0  # Track time for marker rotation

func _ready() -> void:
	beat_interval = 60.0 / bpm
	next_beat_time = 0.0
	audio_player = $AudioStreamPlayer2D
	
	# Center the circle on the screen
	var viewport_size = get_viewport_rect().size
	circle_center = viewport_size / 2

func _process(delta: float) -> void:
	next_beat_time += delta
	# Update marker rotation based on beat interval (2 beats per rotation)
	current_time = fmod(next_beat_time, beat_interval * 2) / (beat_interval * 2)  # Normalize to 0-1 range
	queue_redraw()

func _draw() -> void:
	# Draw main circle
	# draw_arc(circle_center, circle_radius, 0, TAU, 64, Color.WHITE, 2.0, true)
	
	# Draw horizontal line through circle
	# draw_line(
	# 	Vector2(circle_center.x - circle_radius, circle_center.y),  # Start point
	# 	Vector2(circle_center.x + circle_radius, circle_center.y),  # End point
	# 	Color.WHITE,  # Same color as circle
	# 	2.0  # Line thickness
	# )
	
	# Draw rotating marker
	if drawMarker:
		var marker_angle = current_time * TAU  
		# var marker_pos = circle_center + Vector2(cos(marker_angle), sin(marker_angle)) * circle_radius
		# draw_line(circle_center, marker_pos, Color.YELLOW, 2.0)
		$Vinyl.rotation = marker_angle
	
	# Draw timing points 
	for point in timing_points:
		var angle = point * TAU  
		var point_pos = circle_center + Vector2(cos(angle), sin(angle)) * circle_radius
		draw_circle(point_pos, 5, Color.RED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		# Calculate how many beats have passed
		var beats_passed = floor(next_beat_time / beat_interval)
		# Get the time of the closest beat
		var closest_beat_time = beat_interval * beats_passed
		# If we're closer to the next beat than the previous beat, use the next beat
		if (next_beat_time - closest_beat_time) > (beat_interval / 2):
			closest_beat_time += beat_interval
		# Calculate timing difference (can be negative or positive)
		var timing_difference = next_beat_time - closest_beat_time
		var delay_ms = timing_difference * 1000
		delayLabel.text = "Delay:\n %.1f ms" % delay_ms
		
		# Store timing difference and calculate average
		timing_differences.append(timing_difference)
		if timing_differences.size() > 10: 
			timing_differences.pop_front()
		
		# Calculate and display average delay
		average_delay = 0.0
		for diff in timing_differences:
			average_delay += diff
		average_delay = (average_delay / timing_differences.size())
		var display_average_delay = average_delay * 1000
		averageDelayLabel.text = "Average Delay:\n %.1f ms" % display_average_delay
		
		# Add timing point to visualization
		timing_points.append(current_time)
		if timing_points.size() > 10:
			timing_points.pop_front()


func _on_button_button_up() -> void:
	if average_delay > 0.0:
		Globals.timeDelay = average_delay
		print("time delay: ", Globals.timeDelay)
	get_tree().change_scene_to_file("res://ui/options.tscn")
