extends AnimatedSprite2D

var speed: float = 250.0  # Pixels per second
var initial_x: float
var initial_y: float

func _ready() -> void:
	# Store initial position
	initial_x = position.x
	initial_y = position.y

func _process(delta: float) -> void:
	position.x -= speed * delta
	
	# Reset position when offscreen
	if position.x < -200:
		position.x = initial_x
		# Randomly vary y position
		position.y = initial_y + randf_range(0, 500)
