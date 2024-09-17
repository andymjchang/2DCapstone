extends Node2D

# const values
const measurePixels = 600
var placedBlocks = []
var currentBlock

@export var testBlock : PackedScene
@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
var bpm : int = 4
var stepSize : int = 100

func _on_text_edit_text_changed() -> void:
	if bpmLabel.text.is_valid_int():
		bpm = int(bpmLabel.text)
		$measureLines.beatsPerMeasure = bpm
		$measureLines.queue_redraw()


func _on_test_placer_button_down() -> void:
	var blockInstance = testBlock.instantiate()
	add_child(blockInstance)
	blockInstance.position = Vector2(450, 450)
	currentBlock = blockInstance


func _on_right_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.x += stepSize
	


func _on_left_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.x -= stepSize


func _on_text_edit_2_text_changed() -> void:
	if stepLabel.text.is_valid_int():
		var step = int(stepLabel.text)
		if (step >= 10):
			stepSize = step
			$measureLines.stepSize = stepSize
			$measureLines.queue_redraw()
