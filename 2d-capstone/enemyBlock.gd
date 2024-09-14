extends MyBaseObject
var blockEnemy
var colliderUpperLeft
var colliderLowerRight
var curBlock
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blockEnemy = get_node("Enemy")
	curBlock = get_node("Block/CollisionShape2D2").shape as RectangleShape2D
	#get the upper limits of the block so that we can bind the enemy to it 
	size = curBlock.extents * 2
	var pos = get_node("Block/CollisionShape2D2").position
	colliderUpperLeft = pos - curBlock.extents
	colliderLowerRight = pos + curBlock.extents
	
	#starting off we are gonna bind the enemy to the center. We need min y and mid x
	var centerX = (colliderUpperLeft.x + colliderLowerRight.x)/2
	var centerCoords = Vector2(centerX, colliderUpperLeft.y-20)
	
	blockEnemy.position = centerCoords
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#question, should I constantly be changing the upper bound values?
	
	pass
	
#func bindToNearestBeat():
	
