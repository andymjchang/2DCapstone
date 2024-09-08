extends Node2D

@onready var label

func _ready():
	label = $RichTextLabel

func initText(text, player_position):
	label = $RichTextLabel
	var labelText = ""
	if text > 90:
		labelText = "Perfect!"
	elif text > 70:
		labelText = "Good!"
	else: 
		labelText = "Missed!"
	label.text = "[center]" + labelText
	position = player_position

func _process(_delta: float) -> void:
	label.position.y -= 1
	label.modulate.a -= 0.02
	if label.position.y >= 45:
		queue_free()
