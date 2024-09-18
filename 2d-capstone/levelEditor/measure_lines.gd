extends Node2D

var measurePixels = 600
var beatsPerMeasure = 3
var stepSize = 150  # This will define the spacing for the grid lines
var viewport_width
var viewport_height

func _ready():
	viewport_width = get_viewport_rect().size.x
	viewport_height = get_viewport_rect().size.y

func _process(_delta):
	# Trigger redraw every frame
	queue_redraw()

func _draw():
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var zoom = camera.zoom
	var camera_pos = camera.global_position

	# Calculate visible area
	var top_left = camera_pos - Vector2(viewport_width, viewport_height) / (2 * zoom)
	var bottom_right = camera_pos + Vector2(viewport_width, viewport_height) / (2 * zoom)

	# Adjust grid drawing based on zoom
	var adjusted_step = stepSize * zoom.x
	var adjusted_measure = measurePixels * zoom.x

	# Calculate grid start and end positions
	var start_x = floor(top_left.x / adjusted_step) * adjusted_step
	var end_x = ceil(bottom_right.x / adjusted_step) * adjusted_step
	var start_y = floor(top_left.y / adjusted_step) * adjusted_step
	var end_y = ceil(bottom_right.y / adjusted_step) * adjusted_step

	# Draw grid lines
	for y in range(start_y, end_y, adjusted_step):
		draw_line(Vector2(start_x, y), Vector2(end_x, y), Color.GRAY, 2.0 / zoom.x)

	for x in range(start_x, end_x, adjusted_step):
		draw_line(Vector2(x, start_y), Vector2(x, end_y), Color.GRAY, 2.0 / zoom.x)

	# Draw measure lines
	var measure_start_x = floor(top_left.x / adjusted_measure) * adjusted_measure
	for x in range(measure_start_x, end_x, adjusted_measure):
		draw_line(Vector2(x, start_y), Vector2(x, end_y), Color.RED, 2.0 / zoom.x)

		# Subdivide each measure based on beatsPerMeasure
		if beatsPerMeasure > 1:
			var beat_interval = adjusted_measure / beatsPerMeasure
			for b in range(1, beatsPerMeasure):
				var beat_x = x + b * beat_interval
				draw_line(Vector2(beat_x, start_y), Vector2(beat_x, end_y), Color.GREEN, 2.0 / zoom.x)
