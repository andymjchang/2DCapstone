extends Control
var enemiesLoaded = false
signal increaseScore
var numEnemies = 0.0
var enemiesHit = 0.0


func _ready() -> void:
	numEnemies = self.get_parent().get_parent().get_node("objectList/enemies").get_child_count()
	self.increaseScore.connect(_scoreIncrease)
	# Initialize the progress bar values
	self.min_value = 0
	self.max_value = 100
	self.value = 0  # Start at zero

func _scoreIncrease() -> void:
	self.value = self.value + 1
	enemiesHit += 1
	Globals.percentageHit = (enemiesHit/numEnemies) * 100
	
	
	

	
