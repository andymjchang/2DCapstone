extends Node2D

#(1,0) (1,1) (1,3)
#2.0 2,1 2,3
#6 layers default
@onready var tileMap = self.get("Node2D/TileMapLayer")
var numCols = 6
var extents
var fillerTiles = [Vector2(1,0),Vector2(1,1), Vector2(1,3)]
var endTiles = [Vector2(2,0),Vector2(2,1), Vector2(2,3)]
var tileWidth
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tileMap =  self.get_node("Node2D/TileMapLayer")
	tileWidth = tileMap.tile_set.tile_size.x * tileMap.scale.x
	print("tile width, ", tileWidth)
	extents = self.get_node("Node2D/Area2D/CollisionShape2D").shape as RectangleShape2D
	extents = extents.extents

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
	print("node, ",self.get_node("Node2D/EditorArea0/CollisionShape2D").get_children())
	#alter the area2d to represent the new size
	self.get_node("Node2D/EditorArea0/CollisionShape2D").shape.extents.x += tileWidth
	self.get_node("Node2D/EditorArea0/CollisionShape2D").global_position.x += tileWidth
	
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
	
	
