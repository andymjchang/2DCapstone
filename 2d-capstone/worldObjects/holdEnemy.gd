extends Node2D

@onready var headSprite: Sprite2D = $SlideEnemyHead
@onready var bodySprites = $Segments
@onready var tailSprite: Sprite2D = $SlideEnemyEnd

var squash_speed: float = 2.0  # Adjust this value to control squashing speed
var is_squashing: bool = false
var original_width: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		start_squash()
		print("squash")
	if is_squashing:
		var new_scale = bodySprites.scale.x - (delta * squash_speed)
		if new_scale > 0:
			bodySprites.scale.x = new_scale
			# Move head closer to tail based on scale change
			headSprite.position.x = original_width * new_scale
		else:
			is_squashing = false

func start_squash():
	is_squashing = true
	original_width = bodySprites.scale.x
