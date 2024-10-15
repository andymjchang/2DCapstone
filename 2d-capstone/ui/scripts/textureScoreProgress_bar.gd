extends TextureProgressBar
var enemiesLoaded = false
signal increaseScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set the bar length to how many enemies there are in a scene
	#	audioPlayer = self.get_parent().get_parent().get_node("Camera2D/Music")
	var numEnemies = self.get_parent().get_parent().get_node("objectList/enemies").get_child_count()
	self.increaseScore.connect(_scoreIncrease)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var numEnemies = self.get_parent().get_parent().get_node("objectList/enemies").get_child_count()
	if numEnemies > 0 and!enemiesLoaded:
		enemiesLoaded = true
		self.min_value = 0
		self.max_value = numEnemies
	
	


func _scoreIncrease() -> void:
	#enemy has died
	self.value = self.value + 1
	
	

	
