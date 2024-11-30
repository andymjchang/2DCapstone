extends Node2D
class_name platformBlockScene
#6 cols  default
@onready var tileMap = self.get("Node2D/TileMapLayer")
@onready var base = $Node2D/base
#this is the default for now
var numCols = 20
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
	setStartTiles()
	setFillerTiles()
	setEndTiles()
	
func initScene() -> void:
	if !hasBeenSet:
		tileMap =  self.get_node("Node2D/TileMapLayer")
		tileWidth = tileMap.tile_set.tile_size.x * tileMap.scale.x
		var newWidth = tileWidth * 20.0
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
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	var startX = minMax[0].x 
	var startY = minMax[0].y
	
	var endX = minMax[1].x
	var endY = minMax[1].y
	#we have to reset the end of the tile so that it doesnt look weird
	
	#we want to move the end cap down by two cols
	for i in range(0,3):
			#starts at the furthest left box of the end tiles
			var curX = minMax[1].x - i
			for j in range(startY,endY+1):
				var atlasCoords = tileMap.get_cell_atlas_coords(Vector2i(curX, j))
				tileMap.set_cell(Vector2i(curX+2, j), 1, atlasCoords)
				#erase the old end cap
				tileMap.erase_cell(Vector2i(curX, j))
				
				
	#now we need to add tiles in the blank two spaces we have created
	#we want to get a random index into our filler array
	var randIndex = int(randf_range(0,6))
	var tiles = fillerTiles[randIndex]
	var curX = minMax[1].x - 2.0
	
	var tileIndex = 0
	#fill in the blanks
	for j in range(startY,endY+1):
		#we set the start row
		var curAtlasCoordPair = tiles[tileIndex]
		tileMap.set_cell(Vector2i(curX, j), 1, curAtlasCoordPair[0])
		tileMap.set_cell(Vector2i(curX+1, j), 1, curAtlasCoordPair[1])
		tileIndex+=1
			
	#extent shifting
	self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x += tileWidth
	self.get_node("Node2D/EditorArea0").global_position.x += tileWidth
	newPos = self.get_node("Node2D/EditorArea0").global_position.x
	extents = self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x
	numCols+=2
	
#decrease by 2 rows, cant delete the start or end blocks
func decreaseByOneTile() -> void: 
	if numCols > 6:
		var usedCells = tileMap.get_used_cells()
		var minMax = getMaxMinCoord(usedCells)
		#we want to delete one col
		var startX = minMax[0].x
		var startY = minMax[0].y
		
		var endX = minMax[1].x
		var endY = minMax[1].y
		
		var moveY = startY

		
		#we want to delete two rows, but not excluding at the end
		for i in range (0,2):
			var curX = endX - (i + 3)
			moveY = startY
			for j in range(startY,endY+1):
				tileMap.erase_cell(Vector2i(curX, moveY))
				moveY+=1

		startY = minMax[0].y
		moveY = startY
		#add in end cap
		
		#shift down the end tiles
		for i in range(2,-1,-1):
			#starts at the furthest left box of the end tiles
			var curX = minMax[1].x - i
			for j in range(startY,endY+1):
				var atlasCoords = tileMap.get_cell_atlas_coords(Vector2i(curX, j))
				tileMap.set_cell(Vector2i(curX-2, j), 1, atlasCoords)
				tileMap.erase_cell(Vector2i(curX, j))

		#extent shiftimg	
		self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x -= tileWidth
		self.get_node("Node2D/EditorArea0").global_position.x -= tileWidth
		newPos = self.get_node("Node2D/EditorArea0").global_position.x 
		extents = self.get_node("Node2D/EditorArea0/%CollisionShape2D").shape.extents.x
		numCols-=2
	
	
#gets the bound of a platforms tile map
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
	
#called when tiles are loaded into the editor
func setTileMaps(posPoints : Array) -> void:
	if posPoints.size() > 2:
		#did this when we changed how many tiles long a default block was
		if posPoints[2] == 12:
			posPoints[2] = 20
		#dont do anything if the block being loaded in is already default length
		if posPoints[2] < numCols:
			while numCols > posPoints[2]:
				self.decreaseByOneTile()
		elif posPoints[2] > numCols:
			while numCols < posPoints[2]:
				self.extendByOneTile()
				
				
				
#not using this rn
func setStartTiles() -> void:
	#the start blocks are only 1 tile wide, so we just need to 
	#get how long it is
	#TODO minmize doing this
	var usedCells = base.get_used_cells()
	var maxMin = getMaxMinCoord(usedCells)
	var maxY = maxMin[1].y
	var startX = maxMin[0].x
	
	#reset the array
	startTiles = []
	for i in maxY:
		#we need to grab the start tiles, which wi
		startTiles.append(Vector2(startX,i))

#not being used rn
func setEndTiles() -> void:
	var usedCells = base.get_used_cells()
	var maxMin = getMaxMinCoord(usedCells)
	var maxY = maxMin[1].y
	var minY = maxMin[0].y
	var endX = maxMin[1].x
	
	
	#reset the array
	#it has to hold both cols
	
	endTiles = []
	var curCol = []
	
	var allCols = []
	#the end tiles are the last three rows
	for i in range(0,3):
		var curX = endX - i
		curCol = []
		for j in range(minY, maxY+1):
			#we need to grab the end tiles, and store them 
			curCol.append(Vector2(curX,i))
		allCols.append(curCol)
	endTiles = allCols
		
func setFillerTiles() -> void:
	#we do everything in twos
	var arrayOne : Array
	var arrayTwo : Array
	#we dont grab the start or end tiles
	var usedCells = base.get_used_cells()
	var maxMin = getMaxMinCoord(usedCells)
	var minX = maxMin[0].x
	var maxX = maxMin[1].x
	var minY = maxMin[0].y
	var maxY = maxMin[1].y
	
	#start from minx +1 and go to maxx -1
	fillerTiles = []
	
	#store the atlas coords of all the filler tiles, dont include end/start columns
	for currentX in range(minX + 3, maxX-2, 2):
		var nextX = currentX + 1
		var curCoords : Vector2
		var curNextCoords : Vector2
		var coordPair : Array
		var oneLane = []
		#TODO see if there is a better way to do this
		#we want to store the atlas data for two rows in one index
		for j in range(minY,maxY+1):
			curCoords = tileMap.get_cell_atlas_coords(Vector2i(currentX, j))
			curNextCoords = tileMap.get_cell_atlas_coords(Vector2i(currentX + 1, j))
			coordPair = [curCoords,curNextCoords]
			#one lane = two columns
			oneLane.append(coordPair)
		fillerTiles.append(oneLane)
	
