extends StaticBody2D

var activeSprite
var actionIndicators
var curSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	var randIndex = randi_range(0, 1)
	$sprite2D.get_children()[randIndex].visible = true
	activeSprite = 	$sprite2D.get_children()[randIndex]
	#doing this for ease of access
	print("whuh: ",self.get_children())
	print("whuh: ",self.get_parent().name)
	self.get_parent().get_node("Sprite2D").texture = activeSprite
	self.get_parent().get_node("Sprite2D").visible = true
