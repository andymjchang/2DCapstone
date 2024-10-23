extends Camera2D

signal moveCameraY(newYPos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()
	self.moveCameraY.connect(_onMoveCameraY)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.inLevel:
		position.x = position.x + Globals.pixelsPerFrame * delta * Globals.scrollSpeed
		
func moveCamera(newXPos) -> void:
	#based on the x pos, shift the camera to where the characters are
	#I have to calulate how many seconds I would have ran, and then use that as my delta UGHHHH
	#given the characters start x and thier speed of x. how many seconds would they have run
	#we start at x - new pos
	position.x += newXPos

func _onMoveCameraY(newYPos) -> void:
	position.y = newYPos * Globals.scrollSpeed
