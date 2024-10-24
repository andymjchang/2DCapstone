extends Node2D
class_name platformBlockScene
#6 cols  default
@onready var tileMap = self.get("Node2D/TileMapLayer")
var numCols = 12
var extents
var newPos
var fillerTiles = [Vector2(2,1),Vector2(2,2),Vector2(2,2), Vector2(2,4)]
var endTiles = [Vector2(4,1),Vector2(3,2),Vector2(3,2), Vector2(4,4)]
var startTiles = [Vector2(0,1),Vector2(1,2),Vector2(1,3), Vector2(0,4)]
var tileWidth
var allTiles = [startTiles, fillerTiles, endTiles]
@export var hasBeenSet : bool = false






func _ready() -> void:
	# set the extents to the width of the tile x 12
	tileMap =  self.get_node("Node2D/TileMapLayer")
	tileWidth = tileMap.tile_set.tile_size.x * tileMap.scale.x
	
func initScene() -> void:
	if !hasBeenSet:
		tileMap =  self.get_node("Node2D/TileMapLayer")
		tileWidth = tileMap.tile_set.tile_size.x * tileMap.scale.x
		var newWidth = tileWidth * 12.0
		extents = self.get_node("Node2D/Area2D/%CollisionShape2D").shape.extents
		extents = extents
		extents = newWidth/2.0
		self.get_node("Node2D/Area2D/%CollisionShape2D").shape.extents.x = extents
		hasBeenSet = true

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
		
	#alter the area2d to represent the new size
	self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x += tileWidth/2.0
	self.get_node("Node2D/EditorArea0").global_position.x += tileWidth/2.0
	newPos = self.get_node("Node2D/EditorArea0").global_position.x
	extents = self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x
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
		
		
		self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x -= tileWidth/2.0
		self.get_node("Node2D/EditorArea0").global_position.x -= tileWidth/2.0
		newPos = self.get_node("Node2D/EditorArea0").global_position.x 
		extents = self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x
		numCols-=1
	
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
	
#TODO make this work for more than one tilemap
func setTileMaps(posPoints : Array) -> void:
	if posPoints.size() > 2:
		if posPoints[2] < numCols:
			while numCols > posPoints[2]:
				self.decreaseByOneTile()
		elif posPoints[2] > numCols:
			while numCols < posPoints[2]:
				self.extendByOneTile()
