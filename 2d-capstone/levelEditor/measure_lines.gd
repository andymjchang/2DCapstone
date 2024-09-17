extends Node2D

var measurePixels = 600
var beatsPerMeasure = 3
var stepSize = 50  # This will define the spacing for the grid lines

var viewport_width
var viewport_height

func _ready():
	viewport_width = get_viewport_rect().size.x
	viewport_height = get_viewport_rect().size.y

func _draw():
	# Draw grid lines
	for y in range(0, int(viewport_height / stepSize) + 1):
		var grid_y = y * stepSize
		draw_line(Vector2(0, grid_y), Vector2(viewport_width, grid_y), Color.GRAY, 2.0)
	for x in range(0, int(viewport_width / stepSize) + 1):
		var grid_x = x * stepSize
		draw_line(Vector2(grid_x, 0), Vector2(grid_x, viewport_height), Color.GRAY, 2.0)

	# Draw measure lines
	for x in range(0, int(viewport_width / measurePixels) + 1):
		var measure_x = x * measurePixels
		draw_line(Vector2(measure_x, 0), Vector2(measure_x, viewport_height), Color.RED, 2.0)
		
		# Subdivide each measure based on beatsPerMeasure
		if beatsPerMeasure > 1:
			var beat_interval = measurePixels / beatsPerMeasure
			for b in range(1, beatsPerMeasure):
				var beat_x = measure_x + b * beat_interval
				draw_line(Vector2(beat_x, 0), Vector2(beat_x, viewport_height), Color.GREEN, 2.0)
