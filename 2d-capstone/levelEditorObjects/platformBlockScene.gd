extends Node2D


@onready var tileMap = self.get("Node2D/TileMapLayer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("tile m ap, ", self.get_node("Node2D/TileMapLayer"))
	tileMap =  self.get_node("Node2D/TileMapLayer")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("extendBlock") and self.get_parent().index == self.get_parent().get_parent().get_parent().get_parent().currentBlock.index:
		extendByOneTile()
	
func extendByOneTile() -> void : 
	#I need to get the max of the col and rows
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	#we want to start one col over, so start with max x and min y
	var newX = minMax[1].x + 1
	var newY = minMax[0].y
	print("new coords, ", Vector2i(4, 4))
	tileMap.set_cell(Vector2i(newX, newY), 0,Vector2i(-3,0))

	
func decreaseByOneTile() -> void: 
	pass
	
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
		tileMap.set_cell(cell, -1)
			
			
	return [minCoords, maxCoords]
	
	
