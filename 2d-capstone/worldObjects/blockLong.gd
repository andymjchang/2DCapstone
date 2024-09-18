extends StaticBody2D

var activeSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	var randIndex = randi_range(0, 1)
	$sprite2D.get_children()[randIndex].visible = true
	activeSprite = 	$sprite2D.get_children()[randIndex]
