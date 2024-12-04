extends StaticBody2D

@onready var tileMap = self.get_node("sprite2D/TileMapLayer")
var activeSprite
var actionIndicators
var curSprite

var capLength = 3
var numCols = 20
var minCols = 6
var extents
var tileHeight
var fillerTiles = [Vector2(2,1),Vector2(2,2),Vector2(2,2), Vector2(2,4)]
var endTiles = [Vector2(4,1),Vector2(3,2),Vector2(3,2), Vector2(4,4)]
var startTiles = [Vector2(0,1),Vector2(1,2),Vector2(1,3), Vector2(0,4)]
var windowTiles = []
var windowLength = [4, 3, 6]
var windowHeight = 4

var filler2Tiles = [Vector2(4,0),Vector2(4,1),Vector2(4,1) ,Vector2(4,1) ]
var end2Tiles = [Vector2(5,0),Vector2(5,1),Vector2(5,1) ,Vector2(5,1)]
var start2Tiles = [Vector2(0,0),Vector2(0,1),Vector2(0,1) ,Vector2(0,1) ]
var tileWidth	
var allTiles = [startTiles, fillerTiles, endTiles]
var id = 1

@onready var defaultTileMap = $sprite2D/TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	var multiplier = 1.0
	#if we are using the level 3 tile map, we want the end/start caps to be 2 tile maps wide
	#meaning that we have 8 middle pieces, meaning that we cant go less than a total of 4 cols
	if Globals.curFile.begins_with("Level 3"):
		$sprite2D/TileMapLayer.visible = false
		$sprite2D/TileMapLayer3.visible = false
		$sprite2D/TileMapLayer2.visible = true
		tileMap = $sprite2D/TileMapLayer2
		allTiles = [start2Tiles, filler2Tiles, end2Tiles]
		setWindowTiles()
		id = 0
		multiplier = 20.0
		minCols = 6
		numCols = 20
		capLength = 3
	elif Globals.curFile.begins_with("Custom"):
		$sprite2D/TileMapLayer.visible = false
		$sprite2D/TileMapLayer2.visible = false
		$sprite2D/TileMapLayer3.visible = true
		tileMap = $sprite2D/TileMapLayer3
		allTiles = [start2Tiles, filler2Tiles, end2Tiles]
		setWindowTiles()
		id = 2
		multiplier = 20.0
		minCols = 6
		numCols = 20
		capLength = 3
	else:
		$sprite2D/TileMapLayer.visible = true
		$sprite2D/TileMapLayer3.visible = false
		$sprite2D/TileMapLayer2.visible = false
		tileMap = $sprite2D/TileMapLayer
		allTiles = [startTiles, fillerTiles, endTiles]
		id = 1
		multiplier = 20.0
	setFillerTiles()
	tileWidth = tileMap.tile_set.tile_size.x * tileMap.scale.x
	tileHeight = tileMap.tile_set.tile_size.y * tileMap.scale.y 
	var newWidth = tileWidth * multiplier
	extents = self.get_node("CollisionShape2D").shape.extents
	extents = extents
	extents = newWidth/2.0
	self.get_node("CollisionShape2D").shape.extents.x = extents
		
func extendByOneTile() -> void : 
	#I need to get the max of the col and rows
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	#we want to start one col over, so start with max x and min y
	var startX = minMax[0].x 
	var startY = minMax[0].y
	
	var endX = minMax[1].x
	var endY = minMax[1].y
	#we have to reset the end of the tile so that it doesnt look weird
	
	#we want to move the end cap down by two for all of them 
	for i in range(0,capLength):
			#starts at the furthest left box of the end tiles
			var curX = minMax[1].x - i
			for j in range(startY,endY+1):
				var atlasCoords = tileMap.get_cell_atlas_coords(Vector2i(curX, j))
				tileMap.set_cell(Vector2i(curX+2, j), id, atlasCoords)
				tileMap.erase_cell(Vector2i(curX, j))
				
				
	#now we need to add in the blank two spaces we have created
	
	#we want to get a random index into our filler array
	#print("filler tile size: ", fillerTiles.size())
	var randIndex = int(randf_range(0,fillerTiles.size()))
	var tiles = fillerTiles[randIndex]
	
	#now we want to loop through the tiles and set them 
	
	var curX = minMax[1].x - 2.0
	
	var tileIndex = 0
	for j in range(startY,endY+1):
		#we set the start row
		var curAtlasCoordPair = tiles[tileIndex]
		tileMap.set_cell(Vector2i(curX, j), id, curAtlasCoordPair[0])
		tileMap.set_cell(Vector2i(curX+1, j), id, curAtlasCoordPair[1])
		tileIndex+=1
			
	#alter the area2d to represent the new size
	self.get_node("CollisionShape2D").shape.extents.x += tileWidth
	self.get_node("CollisionShape2D").global_position.x += tileWidth
	numCols+=2
	
func decreaseByOneTile() -> void: 
	if numCols > minCols:
		var usedCells = tileMap.get_used_cells()
		var minMax = getMaxMinCoord(usedCells)
		#we want to delete one col
		var startX = minMax[0].x
		var startY = minMax[0].y
		
		var endX = minMax[1].x
		var endY = minMax[1].y
		
		var moveY = startY

		#we want to delete two rows, but not starting at the end
		for i in range (0,2):
			var curX = endX - (i + capLength)
			moveY = startY
			for j in range(startY,endY+1):
				#print("deleting coords: ",curX," , ", moveY)
				tileMap.erase_cell(Vector2i(curX, moveY))
				moveY+=1

		startY = minMax[0].y
		moveY = startY
		#add in end cap
		var startNum = 2 if capLength == 3 else 1
		for i in range(startNum,-1,-1):
			#starts at the furthest left box of the end tiles
			var curX = minMax[1].x - i
			for j in range(startY,endY+1):
				var atlasCoords = tileMap.get_cell_atlas_coords(Vector2i(curX, j))
				tileMap.set_cell(Vector2i(curX-2, j), id, atlasCoords)
				tileMap.erase_cell(Vector2i(curX, j))

			
		self.get_node("CollisionShape2D").shape.extents.x -= tileWidth
		self.get_node("CollisionShape2D").global_position.x -= tileWidth
		numCols-=2
	
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
	
func setTileMaps(posPoints : Array):
	#print("setting tile maps")
	if posPoints.size() >= 3:
		#if posPoints[2] == 12:
			#posPoints[2]=20
		#if id == 0:
			#posPoints[2] -= 2
		if posPoints[2] < numCols:
			while numCols > posPoints[2]:
				self.decreaseByOneTile()
		elif posPoints[2] > numCols:
			while numCols < posPoints[2]:
				self.extendByOneTile()
		
		if id == 0:
			placeWindows()
				
func setFillerTiles() -> void:
	#we do everything in twos
	var arrayOne : Array
	var arrayTwo : Array
	#we dont grab the start or end tiles
	var usedCells = tileMap.get_used_cells()
	var maxMin = getMaxMinCoord(usedCells)
	var minX = maxMin[0].x
	var maxX = maxMin[1].x
	var minY = maxMin[0].y
	var maxY = maxMin[1].y
	
	#start from minx +1 and go to maxx -1
	fillerTiles = []
	for currentX in range(minX + capLength, maxX-(capLength-1), 2):
		var nextX = currentX + 1
		var curCoords : Vector2
		var curNextCoords : Vector2
		var coordPair : Array
		var oneLane = []
		#TODO see if there is a better way to do this
		#we are gonna store there atlas coords
		for j in range(minY,maxY+1):
			#var atlasCoords = tileMap.get_cell_atlas_coords(Vector2i(curX, j))
			curCoords = tileMap.get_cell_atlas_coords(Vector2i(currentX, j))
			curNextCoords = tileMap.get_cell_atlas_coords(Vector2i(currentX + 1, j))
			coordPair = [curCoords,curNextCoords]
			oneLane.append(coordPair)
		fillerTiles.append(oneLane)
		#print("added block")
	
func placeWindows() -> void:
	#we want to get a random window style
	var randIndex = int(randf_range(0,3))
	var windowSet = windowTiles[randIndex]
	#add the buffer
	var curLength = windowLength[randIndex]  + 1
	
	#we need to get the maxMin of our current block after all the de/increases
	var usedCells = tileMap.get_used_cells()
	var minMax = getMaxMinCoord(usedCells)
	
	var minX = minMax[0].x
	var maxX = minMax[1].x	
	var maxY = minMax[1].y
	#we are not counting the side portion of the wall
	var length = abs(maxX - minX) - 2
	
	var numWindows = int(length/curLength)
	
	var curX = 0
	#place windows
	for i in range(minX+2, maxX+1, curLength):
		if i <= maxX - 2 - curLength:
		#account for padding
			randIndex = int(randf_range(0,3))
			windowSet = windowTiles[randIndex]
			#add the buffer
			curLength = windowLength[randIndex]  + 1
			for j in range(1, maxY+1, windowHeight+2):
				var upperLeftCorner = Vector2i(i,j)
				placeOneWindow(upperLeftCorner, windowSet, windowLength[1])
	
	
	# we need to divide the length of our block 

func placeOneWindow(start, windowSet, length) -> void:
	
	var index = 0
	#print("placing one window")
	#print("window height:", windowHeight)
	#print("window length:", length)
	#print("window set: ", windowSet)
	#
	#print("x range: ", start.x, " - ", start.x+length)
	#print("y range: ", start.y ," - ", windowHeight)
	for i in range(start.x, start.x+length+1):
		for j in range(start.y, windowHeight+start.y):
			if windowSet.size() > index:
				tileMap.set_cell(Vector2i(i, j), 0, windowSet[index])
				index+=1
	
	
func setWindowTiles() -> void:
	#set the atlas coords of all the windows\
	var windowOne = []
	
	for i in range(0,7):
		for j in range(5, 9):
			var newCoords = Vector2i(i,j)
			windowOne.append(newCoords)
	
	var windowTwo = []
	
	for i in range(6,11):
		for j in range(5, 9):
			var newCoords = Vector2i(i,j)
			windowTwo.append(newCoords)
			
	var windowThree = []
	
	for i in range(10,20):
		for j in range(5, 9):
			var newCoords = Vector2i(i,j)
			windowThree.append(newCoords)
			
	windowTiles = [windowOne, windowTwo, windowThree]
					
