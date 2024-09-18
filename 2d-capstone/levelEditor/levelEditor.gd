extends Node2D

# const values
const measurePixels = 600
var placedBlocks = []
var currentBlock
var saveFileName = "new_scene"

@export var testBlock : PackedScene
@export var actionIndicator : PackedScene
@export var checkpoint : PackedScene
@export var worldManager : Script
@export var levelUI : PackedScene

@onready var objectList = $objectList
@onready var testBlockList = $objectList/testBlocks
@onready var actionIndicatorList = $objectList/actionIndicators
@onready var checkpointList = $objectList/checkpoints
@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
@onready var fileLabel = $UI/TextEdit3
@onready var measureLines = $measureLines

var bpm : int = 4
var stepSize : int = 150

func _ready():
	measureLines.beatsPerMeasure = bpm
	measureLines.stepSize = stepSize

func _on_text_edit_text_changed() -> void:
	if bpmLabel.text.is_valid_int():
		bpm = int(bpmLabel.text)
		measureLines.beatsPerMeasure = bpm
		measureLines.queue_redraw()
func _on_text_edit_2_text_changed() -> void:
	if stepLabel.text.is_valid_int():
		var step = int(stepLabel.text)
		if (step < 25):
			step = 25
		stepSize = step
		measureLines.stepSize = stepSize
		measureLines.queue_redraw()

func _on_text_edit_3_text_changed() -> void:
	saveFileName = fileLabel.text

func _on_test_placer_button_down() -> void:
	var blockInstance = testBlock.instantiate()
	testBlockList.add_child(blockInstance)
	blockInstance.position = Vector2(450, 450)
	currentBlock = blockInstance
func _on_test_placer_2_button_down() -> void:
	var actionInstance = actionIndicator.instantiate()
	actionIndicatorList.add_child(actionInstance)
	actionInstance.position = Vector2(450, 450)
	currentBlock = actionInstance
func _on_test_placer_3_button_down() -> void:
	save_scene_to_file()
func _on_checkpoint_button_pressed() -> void:
	var checkpointInstance = checkpoint.instantiate()
	checkpointList.add_child(checkpointInstance)
	checkpointInstance.position = Vector2(450, 450)
	currentBlock = checkpointInstance
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
	
func _on_right_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.x += stepSize
func _on_left_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.x -= stepSize
func _on_down_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.y += stepSize
func _on_up_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.y -= stepSize
	
func save_scene_to_file():
	var newRoot = objectList.duplicate()
	newRoot.set_script(worldManager)
	#var worldManager = load(** world manager scene path **)
	#var worldManagerInstance = worldManager.instantiate()
	#root.add_child(worldManagerInstance)

	# Add essential level objects

	# UI
	newRoot.add_child(levelUI.instantiate())

	# Camera
	var newCam = Camera2D.new()
	newCam.position.x = get_viewport().size.x / 2
	newCam.position.y = get_viewport().size.y / 2
	newCam.name = "Camera2D"
	newRoot.add_child(newCam)

	# Ensure all nested children have their owner set
	_set_owner_recursive(newRoot, newRoot)

	# Pack scene
	var new_scene = PackedScene.new()
	var result = new_scene.pack(newRoot)
	if result == OK:
		# Save scene
		var scene_path = "res://savedScenes/" + saveFileName + ".tscn"
		var error = ResourceSaver.save(new_scene, scene_path)
		if error == OK:
			print("Scene saved successfully.")	
		else:
			print("Failed to save scene. Error code: ", error)
	else:
		print("Failed to pack scene.")

# Recursive function to set owner for all children
func _set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.set_owner(root)
		_set_owner_recursive(child, root)
