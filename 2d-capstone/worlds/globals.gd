extends Node

var time = 0;
var inLevel = false
var stepSize = 0

var editorNode 
var previewNode

func _process(delta: float) -> void:
	time += delta;
