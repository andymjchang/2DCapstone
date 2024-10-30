extends Node2D

var keyFolderPath = "res://ui/assets/onboarding/keys"
var pathToTarget = ""

#images
@onready var punchImage = preload("res://ui/assets/onboarding/punchGraphic.png")
@onready var slideImage = preload("res://ui/assets/slide.webp")
@onready var activateImage = preload("res://ui/assets/onboarding/activateGraphic.png")
@onready var jumpImage = preload("res://ui/assets/onboarding/jumpGraphic.png")

@onready var sprite = $Node2D/Sprite2D
#default
var instructionType = "punch"
# Called when the node enters the scene tree for the first time.

#paths to images so that can display what we are 
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		



func setInstructionType(newInst) -> void:
	match newInst:
		"punch":
			sprite.texture = punchImage
			instructionType = "punch"
		"slide":
			sprite.texture = slideImage
			instructionType = "slide"
		"jump":
			sprite.texture = jumpImage
			instructionType = "jump"
		"activate":
			sprite.texture = activateImage
			instructionType = "activate"
	
func setImage(posPoints):
	if posPoints.size() > 2:
		setInstructionType(posPoints[2])
