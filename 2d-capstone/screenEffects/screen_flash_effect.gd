extends Node2D

# Nodes
var camera
var initialZoom
@onready var flash_rect = $CanvasLayer/ColorRect

# Optional: Set initial state of the ColorRect
func _ready():
	camera = get_viewport().get_camera_2d()
	flash_rect.color = Color(1, 1, 1, 0.0) 
	
	initialZoom = camera.zoom
	camera.zoom = initialZoom + Vector2(0.25, 0.25)
	
	screenFlash(0, 0)

func screenFlash(speed, strength):
	var tween = create_tween()
	tween.tween_property(flash_rect, "color:a", 0.5, 0.1)
	tween.tween_property(flash_rect, "color:a", 0.0, .4)
	queue_free()
