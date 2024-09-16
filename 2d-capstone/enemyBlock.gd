extends MyBaseObject
var blockEnemy
var colliderUpperLeft
var colliderLowerRight
var curBlock
var dragging = false
var dragDif = Vector2(0,0)
var up
var down 
var left
var right
var beatLength = 0.0
var originPos = Vector2(0,0)
var blockChildren
#TODO create a stack of all the indicators we are using 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	originPos = self.global_position
	#need to add controls to the block
	blockEnemy = get_node("Enemy")
	curBlock = get_node("Block/CollisionShape2D2").shape as RectangleShape2D
	#get the upper limits of the block so that we can bind the enemy to it 
	size = curBlock.extents * 2
	var pos = get_node("Block/CollisionShape2D2").position
	colliderUpperLeft = pos - curBlock.extents
	colliderLowerRight = pos + curBlock.extents
	
	#starting off we are gonna bind the enemy to the center. We need min y and mid x
	var centerX = (colliderUpperLeft.x + colliderLowerRight.x)/2
	#TODO , make this a constant and also find an algortithim way to reposition the enemy
	var centerCoords = Vector2(centerX, colliderUpperLeft.y-20)
	
	blockEnemy.position = centerCoords
	
	#set up block controls, TODO add a check here to see if we are in level editor
	up = "up"
	down = "down"
	left = "left"
	right = "right"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	#question, should I constantly be changing the upper bound values?
	if Input.is_action_just_pressed(up):
		self.global_position.y -= 10
	if Input.is_action_just_pressed(down):
		self.global_position.y += 10
	if Input.is_action_just_pressed(left):
		self.global_position.x -= 10
	if Input.is_action_just_pressed(right):
		self.global_position.x += 10
		#go a certain amount of pixels up 
	if Input.is_action_just_pressed("sizeUp"):
		sizeUp()
	size = curBlock.extents * 2
	var pos = get_node("Block/CollisionShape2D2").global_position
	colliderUpperLeft = pos - curBlock.extents
	colliderLowerRight = pos + curBlock.extents
	bindToNearestBeat()
	pass

	
func bindToNearestBeat():
	#loop through all of the indicators in a scene, if one has x coords that
	# are within the bounds of the block, snap the x coords of the enemy to that x.
	var indicators = get_tree().get_nodes_in_group("indicatorManagers")
	#TODO set closet indicataor x to the first in the list 
	var closetIndicatorX = -1000
	for indicatorList in indicators:
		#sort through all of the indicators
		for indicator in indicatorList.get_children():
			var xDifference = indicator.position.x - self.global_position.x
			if abs(closetIndicatorX - self.global_position.x) > abs(xDifference):
				#we have found a closer beat. 
				closetIndicatorX = indicator.position.x
	#out of for loop and now I have the closest indicators X
	#check to see if that indicator is within the x bounds of our block
	print("Upper left x: ",colliderUpperLeft.x )
	print("Lower right x: ", colliderLowerRight.x)
	print("indicator X", closetIndicatorX)
	if closetIndicatorX >= colliderUpperLeft.x and closetIndicatorX <= colliderLowerRight.x:
		#snap the enemys x coordinates to the beat
		blockEnemy.global_position.x = closetIndicatorX
	elif closetIndicatorX < colliderUpperLeft.x:
		print("closest indicator is to0 the right")
		blockEnemy.global_position.x = colliderUpperLeft.x
	else:
		blockEnemy.global_position.x = colliderLowerRight.x
		
		
		
#TODO add a functionality so that based off of a button press, 
#it extends either right or left
func sizeUp():
	#size up by one beat, to the right
	#theres a better way to do this but I am tire TODO,
	#TODO update indicators list via a process call
	var indicators = get_tree().get_nodes_in_group("indicatorManagers")
	#TODO set closet indicataor x to the first in the list 
	var closetIndicatorX = -1000
	for indicatorList in indicators:
		#sort through all of the indicators
		for indicator in indicatorList.get_children():
			if indicator.position.x >= self.global_position.x:
				#we have found the next beat to extend out to 
				# now we need to know how much to strecth,
				#i dont know how to math im gonna kms
				var goalWidth = abs(indicator.position.x - self.colliderUpperLeft.x)
				var orgWidth = abs(self.colliderLowerRight.x - self.colliderUpperLeft.x)
				var newScale = goalWidth / orgWidth
				self.scale.x *= newScale
				self.global_position.x = self.colliderUpperLeft.x
				
				#ok new method, just craft a whole new enemy block and shit and delete the old ones
				#should I be pre-loading this
				var newEnemy = load("res://enemy/enemy.tscn").new()
				var newColShape = CollisionShape2D.new()
				var newBlock = load("res://worldObjects/blockLong.tscn").new()
				var newEnemyBlock = load("res://shadow/enemy_block.tscn").new()
				var newRectangleShape = RectangleShape2D.new()
				
				
				
				
	
			
				#
				#todo dont scale enemy haha
				self.scale.x *= newScale
				
				
				
			
			
	
	
#func sizeDown():
	#size down by one beat
