extends Node2D

@export var greenTiming : Texture
@export var yellowTiming : Texture
@export var redTiming : Texture

@onready var label
@onready var clefSprite
var fadeMode = false
var trackedNode
var min_rotation
var max_rotation
var clefDefaultPosition

func _ready():
	label = $RichTextLabel
	clefSprite = $clefSprite
	label.text = ""
	clefDefaultPosition = clefSprite.position
	
	clefSprite.modulate.a = 0.0
	
	var min_rotation_degrees = 0
	var max_rotation_degrees = 3
	# Convert degrees to radians for rotation
	min_rotation = min_rotation_degrees * (PI / 180)
	max_rotation = max_rotation_degrees * (PI / 180)

func initPosition(node):
	trackedNode = node
	position = node.get_global_position() - get_parent().position
	position.x += 200

func initText(text, player_position):
	label = $RichTextLabel
	$sfxPlayer.play()
	var labelText = ""
	if text > 80:
		labelText = "PERFECT!"
		clefSprite.texture = greenTiming
	elif text > 50:
		labelText = "GOOD!"
		clefSprite.texture = yellowTiming
	else: 
		labelText = "BARELY!"
		clefSprite.texture = redTiming
	label.text = labelText
	#position.y = player_position.y
	fadeMode = true
	label.modulate.a = 1.0
	
	clefSprite.modulate.a = 1.0
	clefSprite.position = clefDefaultPosition
	
	rotation = randf_range(min_rotation, max_rotation)

func _process(_delta: float) -> void:
	# track player position
	position.y = trackedNode.position.y - get_parent().position.y
	
	# fade
	if fadeMode:
		label.modulate.a -= 0.02
		clefSprite.modulate.a -= 0.02
		clefSprite.position.y -= 0.15
	if label.modulate.a <= 0:
		fadeMode = false
