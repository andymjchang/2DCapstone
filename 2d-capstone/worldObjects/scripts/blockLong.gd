extends StaticBody2D

var activeSprite
var actionIndicators
var curSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	if Globals.curFile.begins_with("Lvl2."):
		$sprite2D/TileMapLayer.visible = false
		$sprite2D/TileMapLayer2.visible = true
	else:
		$sprite2D/TileMapLayer.visible = true
		$sprite2D/TileMapLayer2.visible = false
	#var randIndex = randi_range(0, 1)
	#$sprite2D.get_children()[randIndex].visible = true
	#activeSprite = 	$sprite2D.get_children()[randIndex]
