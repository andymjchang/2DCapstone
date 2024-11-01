extends Node2D

@onready var delayLabel : Label = $Label
var bpm = 120.0
var beat_interval : float
var next_beat_time : float
var audio_player : AudioStreamPlayer2D

# Add new variables for visualization
var circle_center = Vector2(200, 200)  # Position of circle center
var circle_radius = 100
var timing_points = []  # Store recent timing points

var current_time : float = 0.0  # Track time for marker rotation

func _ready() -> void:
	beat_interval = 60.0 / bpm
	next_beat_time = 0.0
	audio_player = $AudioStreamPlayer2D
	print(beat_interval)

func _process(delta: float) -> void:
	if next_beat_time <= 0:
		next_beat_time = beat_interval
	next_beat_time -= delta
	
	# Update marker rotation
	current_time = fmod(current_time + delta, 1.0)  # Keep time between 0 and 1
	queue_redraw()

func _draw() -> void:
	# Draw main circle
	draw_arc(circle_center, circle_radius, 0, TAU, 32, Color.WHITE)
	
	# Draw rotating marker
	var marker_angle = current_time * TAU  # Convert time to angle (full rotation per second)
	var marker_pos = circle_center + Vector2(cos(marker_angle), sin(marker_angle)) * circle_radius
	draw_line(circle_center, marker_pos, Color.YELLOW, 2.0)
	
	# Draw timing points
	for point in timing_points:
		var angle = (point) * TAU  # 0.5 seconds = full half rotation
		var point_pos = circle_center + Vector2(cos(angle), sin(angle)) * circle_radius
		draw_circle(point_pos, 5, Color.RED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var timing_difference = next_beat_time
		var delay_ms = abs(timing_difference - beat_interval) * 1000
		if delay_ms > 250:
			delay_ms = abs(250 - delay_ms)
		delayLabel.text = "Delay: %.1f ms" % delay_ms
		
		# Add timing point to visualization
		timing_points.append(current_time)
		if timing_points.size() > 1:  # Keep last 20 points
			timing_points.pop_front()
