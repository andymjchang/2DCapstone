extends Node2D


#6 cols  default
@onready var tileMap = self.get("Node2D/TileMapLayer")
var numCols = 12
var extents
var fillerTiles = [Vector2(2,1),Vector2(2,2),Vector2(2,2), Vector2(2,4)]
var endTiles = [Vector2(4,1),Vector2(3,2),Vector2(3,2), Vector2(4,4)]
var tileWidth

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
	print("node, ",self.get_node("Node2D/EditorArea0/CollisionShape2D").get_children())
	#alter the area2d to represent the new size
	print("before extending collision shape pos: ", self.get_node("Node2D/EditorArea0/CollisionShape2D").global_position.x , " , extents: ",self.get_node("Node2D/EditorArea0/CollisionShape2D").shape.extents.x, " , tile width: ", tileWidth )
	self.get_node("Node2D/EditorArea0/CollisionShape2D").shape.extents.x += tileWidth
	self.get_node("Node2D/EditorArea0/CollisionShape2D").global_position.x += tileWidth
	print("after extending collision shape pos: ", self.get_node("Node2D/EditorArea0/CollisionShape2D").global_position.x , " , extents: ",self.get_node("Node2D/EditorArea0/CollisionShape2D").shape.extents.x )

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
		#TODO, make sure this is right
		self.get_node("Node2D/EditorArea0/CollisionShape2D").shape.extents.x -= tileWidth
		self.get_node("Node2D/EditorArea0/CollisionShape2D").global_position.x -= tileWidth
		numCols-=1
	
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
	
	
