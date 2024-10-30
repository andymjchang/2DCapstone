extends Node2D

var enemyType = "enemy"


#sprite stuff
@onready var sprite = $Node2D/Sprite2D
@onready var enemyImage = preload("res://worldObjects/assets/singleBot.png")
@onready var slideEnemyImage = preload("res://worldObjects/assets/slideEnemy.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func setEnemyType(newInst) -> void:
	match newInst:
		"enemy":
			sprite.texture = enemyImage
			enemyType = "enemy"
		"slideEnemy":
			sprite.texture = slideEnemyImage
			enemyType = "slideEnemy"
	
	#set the collision based on it 
	var newYExtents = (sprite.texture.get_size().y * sprite.scale.y) / 2.0
	var newXExtents = (sprite.texture.get_size().x * sprite.scale.x) / 2.0
	$Node2D/EditorArea0/CollisionShape2D.shape.extents = Vector2(newXExtents, newYExtents)
		
	
func setImage(posPoints):
	if posPoints.size() > 2:
		print("image name: ", posPoints[2])
		setEnemyType(posPoints[2])
