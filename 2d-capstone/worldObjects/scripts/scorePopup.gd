extends Node2D

@onready var label
var fadeMode = false
var trackedNode
var min_rotation
var max_rotation

func _ready():
	label = $RichTextLabel
	label.text = ""
	
	var min_rotation_degrees = -5
	var max_rotation_degrees = 5
	# Convert degrees to radians for rotation
	min_rotation = min_rotation_degrees * (PI / 180)
	max_rotation = max_rotation_degrees * (PI / 180)

func initPosition(node):
	trackedNode = node
	position = node.get_global_position() - get_parent().position
	position.x += 100

func initText(text, player_position):
	label = $RichTextLabel
	var labelText = ""
	if text > 90:
		labelText = "Perfect!"
	elif text > 70:
		labelText = "Good!"
	else: 
		labelText = "Missed!"
	label.text = labelText
	#position.y = player_position.y
	fadeMode = true
	label.modulate.a = 1.0
	rotation = randf_range(min_rotation, max_rotation)

func _process(_delta: float) -> void:
	# track player position
	position.y = trackedNode.position.y - get_parent().position.y
	
	# fade
	if fadeMode:
		label.modulate.a -= 0.02
	if label.modulate.a <= 0:
		fadeMode = false
