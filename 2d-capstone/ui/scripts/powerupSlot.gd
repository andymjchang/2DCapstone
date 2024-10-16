extends CanvasLayer

@onready var visual : AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	visual = $Container/Powerup
	visual.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# on powerup obtain
func _onGetPowerup():
	pass
