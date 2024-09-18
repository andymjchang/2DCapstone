extends Node

var time = 0;
var inLevel = false
var stepSize = 0

func _process(delta: float) -> void:
	time += delta;
