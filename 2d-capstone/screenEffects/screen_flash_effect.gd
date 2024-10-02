extends Node2D

# Nodes
var camera
var initialZoom
var flash_rect 

func screenFlash(opacity, time):
	flash_rect = $CanvasLayer/ColorRect
	flash_rect.color = Color(1, 1, 1, opacity) 
	var tween = create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, time)
	#queue_free()

func delete():
	queue_free()
