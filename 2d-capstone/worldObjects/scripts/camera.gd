extends Camera2D

signal moveCameraY(newYPos)

var target_position: Vector2
var panning_speed: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()
	self.moveCameraY.connect(_onMoveCameraY)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.inLevel:
		position.x = position.x + Globals.pixelsPerFrame * delta * Globals.scrollSpeed
		
	# Smooth panning only affects Y position
	if Globals.vertical or is_player_on_ground():
		position.y = lerp(position.y, target_position.y, panning_speed * delta)  # Use global lerp function

func moveCamera(newXPos) -> void:
	#based on the x pos, shift the camera to where the characters are
	#I have to calulate how many seconds I would have ran, and then use that as my delta UGHHHH
	#given the characters start x and thier speed of x. how many seconds would they have run
	#we start at x - new pos
	position.x += newXPos

func _onMoveCameraY(newYPos) -> void:
	position.y = newYPos * Globals.scrollSpeed

func smooth_pan_to(new_y: float) -> void:
	target_position.y = new_y  # Only set the Y position for panning

func is_player_on_ground() -> bool:
	# Implement this function to check if the player is on the ground
	# You'll need to add logic to detect the player's state
	# For now, we'll return a placeholder value
	return true  # Replace with actual ground detection logic
