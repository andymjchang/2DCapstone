extends StaticBody2D

@onready var tileMap = self.get_node("sprite2D/TileMapLayer")
var activeSprite
var actionIndicators
var curSprite

var numCols = 12
var extents
var fillerTiles = [Vector2(2,1),Vector2(2,2),Vector2(2,2), Vector2(2,4)]
var endTiles = [Vector2(4,1),Vector2(3,2),Vector2(3,2), Vector2(4,4)]
var startTiles = [Vector2(0,1),Vector2(1,2),Vector2(1,3), Vector2(0,4)]
var tileWidth
var allTiles = [startTiles, fillerTiles, endTiles]

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

func setTileMaps(posPoints : Array):
	var minMax = getMaxMinCoord(tileMap.get_used_cells())
	var curTileSet = allTiles[0]
	var startX = minMax[0].x
	var startY = minMax[0].y
	tileMap.clear()
		
	print()
	
	print("pos points, ", posPoints)
	if posPoints.size() > 2:
		var cols = posPoints[2]
		for col in range(0, cols):
			if col == cols:
				curTileSet = allTiles[2]
			elif col > 0:
				curTileSet = allTiles[1]
			startY = minMax[0].y
			for i in range(0,4):
				#place a tile down
				tileMap.set_cell(Vector2i(startX, startY),1, curTileSet[i])
				startY+=1
			startX+=1
			
		
func getMaxMinCoord(usedCells : Array) -> Array:
	#get the max/min of the tilemap 
	var minCoords = Vector2(INF, INF)
	var maxCoords = Vector2(-INF, -INF)
	
	for cell in usedCells:
		print("cell coords, ", cell)
		if cell.x > maxCoords.x:
			maxCoords.x = cell.x
		if cell.x < minCoords.x:
			minCoords.x = cell.x
		if cell.y > maxCoords.y:
			maxCoords.y = cell.y
		if cell.y < minCoords.y:
			minCoords.y = cell.y
						
	return [minCoords, maxCoords]
