extends Node2D

var measurePixels = 600
var beatsPerMeasure = 3

var viewport_width
var viewport_height

func _ready():
	viewport_width = get_viewport_rect().size.x
	viewport_height = get_viewport_rect().size.y

func _draw():
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
