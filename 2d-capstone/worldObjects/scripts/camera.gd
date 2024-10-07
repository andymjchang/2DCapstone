extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.inLevel:
		position.x = position.x + Globals.pixelsPerFrame * delta
		
func moveCamera(newXPos) -> void:
	#based on the x pos, shift the camera to where the characters are
	position.x = newXPos
