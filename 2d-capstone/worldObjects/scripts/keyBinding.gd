extends Node2D

var pathToImage = ""
var imageName = ""
@onready var sprite = $Sprite2D

@onready var punchImage = preload("res://ui/assets/onboarding/punchGraphic.png")
@onready var slideImage = preload("res://ui/assets/slide.webp")
@onready var activateImage = preload("res://ui/assets/onboarding/activateGraphic.png")
@onready var jumpImage = preload("res://ui/assets/onboarding/jumpGraphic.png")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setImage(posPoints : Array) -> void:
	if posPoints.size() > 2.0:
		var instructionType = posPoints[2]
		print("in world object pos poinst: ", posPoints)
		match instructionType:
			"punch":
				sprite.texture = punchImage
			"slide":
				sprite.texture = slideImage
			"jump":
				sprite.texture = jumpImage
			"activate":
				sprite.texture = activateImage
