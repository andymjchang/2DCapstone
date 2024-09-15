extends Node2D

@onready var bpmLabel = $UI/TextEdit
var bpm : int = 120

func _on_text_edit_text_changed() -> void:
	if bpmLabel.text.is_valid_int():
		bpm = int(bpmLabel.text)
		print("bpm: " + bpmLabel.text)
