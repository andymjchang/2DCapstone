extends Node2D

var measurePixels = 600
var beatsPerMeasure = 3
var stepSize = 150  # This defines the fixed spacing for the grid lines
var viewport_width
var viewport_height
@export var font : Font

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

	# Calculate grid start and end positions (fixed spacing)
	var start_x = floor(top_left.x / stepSize) * stepSize
	var end_x = ceil(bottom_right.x / stepSize) * stepSize
	var start_y = floor(top_left.y / stepSize) * stepSize
	var end_y = ceil(bottom_right.y / stepSize) * stepSize

	# Draw grid lines (fixed spacing)
	for y in range(start_y, end_y + 1, stepSize):
		draw_line(Vector2(start_x, y), Vector2(end_x, y), Color.GRAY, 2.0 / zoom.x)
	for x in range(start_x, end_x + 1, stepSize):
		draw_line(Vector2(x, start_y), Vector2(x, end_y), Color.GRAY, 2.0 / zoom.x)

	# Draw measure lines (fixed spacing) and label them
	var measure_start_x = floor(top_left.x / measurePixels) * measurePixels
	var measure_end_x = ceil(bottom_right.x / measurePixels) * measurePixels

	for x in range(measure_start_x, measure_end_x + 1, measurePixels):
		draw_line(Vector2(x, top_left.y), Vector2(x, bottom_right.y), Color.RED, 2.0 / zoom.x)
		
		# Calculate and draw measure number
		var measure_number = int(x / measurePixels) + 1
		var label_pos = Vector2(x, top_left.y + 25)
		draw_string(font, label_pos, str(measure_number), HORIZONTAL_ALIGNMENT_CENTER, -1, 16 / zoom.x, Color.WHITE)

		# Subdivide each measure based on beatsPerMeasure
		if beatsPerMeasure > 1:
			var beat_interval = measurePixels / beatsPerMeasure
			for b in range(1, beatsPerMeasure):
				var beat_x = x + b * beat_interval
				draw_line(Vector2(beat_x, top_left.y), Vector2(beat_x, bottom_right.y), Color.GREEN, 2.0 / zoom.x)
