extends Control
var enemiesLoaded = false
signal increaseScore
var numEnemies = 0.0
var enemiesHit = 0.0

var textureBar


func _ready() -> void:
	AssignTextureBar()
	numEnemies = self.get_parent().get_parent().get_node("objectList/enemies").get_child_count()
	self.increaseScore.connect(_scoreIncrease)
	# Initialize the progress bar values
	textureBar.min_value = 0
	textureBar.max_value = 100
	textureBar.value = 0  # Start at zero

func AssignTextureBar() -> void:
	if Globals.curFile == "Level 1" or Globals.curFile.begins_with("Tutorial") or Globals.curFile == "Level 2":
		textureBar = get_node("Level1")
	elif Globals.curFile == "Level 3":
		textureBar = get_node("Level2")
	else:
		textureBar = get_node("Level3")

	textureBar.visible = true

func _scoreIncrease() -> void:
	textureBar.value = textureBar.value + 1
	enemiesHit += 1
	Globals.percentageHit = (enemiesHit/numEnemies) * 100
	
	
	

	
