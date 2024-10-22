extends StaticBody2D

@onready var tileMap = self.get_node("sprite2D/TileMapLayer")
var activeSprite
var actionIndicators
var curSprite

var numCols = 12
var extents
var tileHeight
var fillerTiles = [Vector2(2,1),Vector2(2,2),Vector2(2,2), Vector2(2,4)]
var endTiles = [Vector2(4,1),Vector2(3,2),Vector2(3,2), Vector2(4,4)]
var startTiles = [Vector2(0,1),Vector2(1,2),Vector2(1,3), Vector2(0,4)]
var tileWidth
var allTiles = [startTiles, fillerTiles, endTiles]

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	tileWidth = tileMap.tile_set.tile_size.x * tileMap.scale.x
	tileHeight = tileMap.tile_set.tile_size.y * tileMap.scale.y 
	var newWidth = tileWidth * 12.0
	extents = self.get_node("CollisionShape2D").shape.extents
	extents = extents
	extents = newWidth/2.0
	self.get_node("CollisionShape2D").shape.extents.x = extents
	if Globals.curFile.begins_with("Lvl2."):
		$sprite2D/TileMapLayer.visible = false
		$sprite2D/TileMapLayer2.visible = true
	else:
		$sprite2D/TileMapLayer.visible = true
		$sprite2D/TileMapLayer2.visible = false
		
func extendByOneTile() -> void : 
	#I need to get the max of the col and rows
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	#we want to start one col over, so start with max x and min y
	var startX = minMax[1].x 
	var startY = minMax[0].y
		#we have to reset the end of the tile so that it doesnt look weird
	for i in range (0,4):
		tileMap.set_cell(Vector2i(startX, startY+i), 1, fillerTiles[i])
		
	startX = minMax[1].x + 1
	startY = minMax[0].y
	for i in range(0,4):
		tileMap.set_cell(Vector2i(startX, startY), 1, endTiles[i])
		startY+=1
		
	#alter the area2d to represent the new size
	self.get_node("CollisionShape2D").shape.extents.x += tileWidth/2.0
	self.get_node("CollisionShape2D").global_position.x += tileWidth/2.0
	numCols+=1

func decreaseByOneTile() -> void: 
	if numCols > 1:
		var usedCells = tileMap.get_used_cells()
		var minMax = getMaxMinCoord(usedCells)
		#we want to delete one col
		var startX = minMax[1].x
		var startY = minMax[0].y
		for i in range(0,4):
			tileMap.erase_cell(Vector2i(startX, startY))
			startY+=1
		
		startX-=1
		startY = minMax[0].y
		for i in range (0,4):
			tileMap.set_cell(Vector2i(startX, startY), 1, endTiles[i])
			startY+=1
			
		self.get_node("CollisionShape2D").shape.extents.x -= tileWidth/2.0
		self.get_node("CollisionShape2D").global_position.x -= tileWidth/2.0
		numCols-=1

func setTileMaps(posPoints : Array):
	if posPoints.size() >= 3:
		if posPoints[2] < numCols:
			while numCols > posPoints[2]+1:
				self.decreaseByOneTile()
		elif posPoints[2] > numCols-1:
			while numCols < posPoints[2]:
				self.extendByOneTile()

					
func getMaxMinCoord(usedCells : Array) -> Array:
	#get the max/min of the tilemap 
	var minCoords = Vector2(INF, INF)
	var maxCoords = Vector2(-INF, -INF)
	
	for cell in usedCells:
		if cell.x > maxCoords.x:
			maxCoords.x = cell.x
		if cell.x < minCoords.x:
			minCoords.x = cell.x
		if cell.y > maxCoords.y:
			maxCoords.y = cell.y
		if cell.y < minCoords.y:
			minCoords.y = cell.y
						
	return [minCoords, maxCoords]
