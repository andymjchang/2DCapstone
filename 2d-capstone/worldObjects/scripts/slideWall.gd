extends StaticBody2D

var activeSprite
var actionIndicators
var curSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
