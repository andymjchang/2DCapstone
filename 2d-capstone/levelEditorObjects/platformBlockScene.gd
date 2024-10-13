extends Node2D

#(1,0) (1,1) (1,3)
#2.0 2,1 2,3
@onready var tileMap = self.get("Node2D/TileMapLayer")
var fillerTiles = [Vector2(1,0),Vector2(1,1), Vector2(1,3)]
var endTiles = [Vector2(2,0),Vector2(2,1), Vector2(2,3)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("tile m ap, ", self.get_node("Node2D/TileMapLayer"))
	tileMap =  self.get_node("Node2D/TileMapLayer")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("extendBlock") and self.get_parent().index == self.get_parent().get_parent().get_parent().get_parent().currentBlock.index:
		extendByOneTile()
	if Input.is_action_just_pressed("reduceBlock") and self.get_parent().index == self.get_parent().get_parent().get_parent().get_parent().currentBlock.index:
		decreaseByOneTile()
	
func extendByOneTile() -> void : 
	#I need to get the max of the col and rows
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	#we want to start one col over, so start with max x and min y
	
	#we have to reset the end of the tile so that it doesnt look weird
	
	var startX = minMax[1].x 
	var startY = minMax[0].y
	
	for i in range (0,3):
		tileMap.set_cell(Vector2i(startX, startY+i), 1, fillerTiles[i])
		
	startX = minMax[1].x + 1
	startY = minMax[0].y
	for i in range(0,3):
		tileMap.set_cell(Vector2i(startX, startY), 1, endTiles[i])
		startY+=1
	
func decreaseByOneTile() -> void: 
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	#we want to delete one col
	var startX = minMax[1].x
	var startY = minMax[0].y
	for i in range(0,3):
		tileMap.erase_cell(Vector2i(startX, startY))
		startY+=1
	
	startX-=1
	startY = minMax[0].y
	for i in range (0,3):
		tileMap.set_cell(Vector2i(startX, startY), 1, endTiles[i])
		startY+=1
	
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
		#tileMap.set_cell(cell, -1)
			
			
	return [minCoords, maxCoords]
	
	
