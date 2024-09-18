extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var randIndex = randi_range(0, 1)
	$sprite2D.get_children()[randIndex].visible = true
