extends StaticBody2D

var activeSprite
var actionIndicators
var curSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	var extents = $Area2D/CollisionShape2D.shape.extents

	print("My length: ", extents.x * 2.0, " my width: ", extents.y * 2.0)
	if Globals.curFile.begins_with("Level 3"):
		$TileMapLayer.visible = false
		$TileMapLayer2.visible = true
	elif Globals.curFile.begins_with("BossLevel"):
		$TileMapLayer.visible = false
		$TileMapLayer2.visible = false
		$TileMapLayer3.visible = true
	else:
		$TileMapLayer.visible = true
		$TileMapLayer2.visible = false
