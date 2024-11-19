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
	var startX = minMax[0].x 
	var startY = minMax[0].y
	
	var endX = minMax[1].x
	var endY = minMax[1].y
	#we have to reset the end of the tile so that it doesnt look weird
	for i in range (startY,endY):
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
		var startX = minMax[0].x
		var startY = minMax[0].y
		
		var endX = minMax[1].x
		var endY = minMax[1].y
		
		var moveY = startY
		print("start coords ",startX," , ", startY)
		print("end coords ",endX," , ", endY)
		#deleting the end, might need to do this twice
		
		#we want to delete two rows, but not starting at the end
		for i in range (0,2):
			var curX = endX - (i +3)
			moveY = startY
			for j in range(startY,endY+1):
				print("deleting coords: ",curX," , ", moveY)
				tileMap.erase_cell(Vector2i(curX, moveY))
				moveY+=1
		
		
		#now we need to shift the current end by 2 blocks
		#setting the X to the new end
		#endX-=1
		startY = minMax[0].y
		moveY = startY
		#add in end cap
		var endStart = endTiles[1][0].y
		var endEnd = endTiles[1][endTiles[1].size()-1].y
		
		
		#the way end tiles is set up
		#  col 1 col 2 col 3
		#   1     1     1
		#
		for i in range(0,3):
			#starts at the furthest right box of the end tiles
			var curX = endX - i
			var curCol = endTiles[i]
			var colIndex = 0
			for j in range(startY,endY+1):
				var atlasCoords = tileMap.get_cell_atlas_coords(Vector2i(curX, j))
				tileMap.set_cell(Vector2i(curX-2, j-1), 1, Vector2i(curX, j))
				tileMap.erase_cell(Vector2i(curX, j))
				#tileMap.set_cell(Vector2i(curX, startY), 1, curCol[colIndex])
				#colIndex+=1
		#for i in 2:
			#var curEndSet = endTiles[i]
			#print("end tiles we are setting: ", endTiles[i])
			#tileMap.set_cell(Vector2i(endX-1, moveY), 1, curEndSet[0])
			#tileMap.set_cell(Vector2i(endX, moveY), 1, curEndSet[1])
			#moveY+=1
		#
		#moveY = endEnd+2
		#for i in range(endEnd+2, endY+1):
			#tileMap.erase_cell(Vector2i(endX, moveY))
			#moveY+=1
			
		
		
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
	
	print("new min max, ", [minCoords, maxCoords])		
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

func setEndTiles() -> void:
	var usedCells = base.get_used_cells()
	var maxMin = getMaxMinCoord(usedCells)
	var maxY = maxMin[1].y
	var minY = maxMin[0].y
	var endX = maxMin[1].x
	
	
	#reset the array
	#it has to hold both cols
	print("max y: ", maxY, " minY:", minY)
	
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
	var maxY = maxMin[1].x
	#start from minx +1 and go to maxx -1
	fillerTiles = []
	for currentX in range(minX + 1, maxX, 2):
		var nextX = currentX + 1
		var curCoords : Vector2
		var curNextCoords : Vector2
		var coordPair : Array
		var oneLane = []
		#TODO see if there is a better way to do this
		for currentY in maxY:
			curCoords = Vector2(currentX, currentY)
			curNextCoords = Vector2(currentX + 1, currentY)
			coordPair = [curCoords,curNextCoords]
			oneLane.append(coordPair)
		fillerTiles.append(oneLane)
	
