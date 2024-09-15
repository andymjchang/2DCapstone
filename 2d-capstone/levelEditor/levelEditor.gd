extends Node2D

# const values
const measurePixels = 600
var placedBlocks = []

@export var testBlock : PackedScene
@onready var bpmLabel = $UI/TextEdit
var bpm : int = 4

func _on_text_edit_text_changed() -> void:
	if bpmLabel.text.is_valid_int():
		bpm = int(bpmLabel.text)
		$measureLines.beatsPerMeasure = bpm
		$measureLines.queue_redraw()


func _on_test_placer_button_down() -> void:
	pass # Replace with function body.
