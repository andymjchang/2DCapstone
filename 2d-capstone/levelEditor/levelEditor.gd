extends Node2D

# const values
const measurePixels = 600
const holdTime = 0.075

var placedBlocks = []
var currentBlock
var currentPosition : Vector2 = Vector2(450, 450)
var trackingPosition : bool = false
var defaultSpawnPosition = Vector2(450, 450)
var timeHeld = 0.0

@export var testBlock : PackedScene
@export var actionIndicator : PackedScene

@onready var objectList = $objectList
@onready var testBlockList = $objectList/testBlocks
@onready var actionIndicatorList = $objectList/actionIndicators
@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
@onready var measureLines = $measureLines
@onready var camera = $Camera2D

var bpm : int = 4
var stepSize : int = 150

func _ready():
	measureLines.beatsPerMeasure = bpm
	measureLines.stepSize = stepSize
	
func _process(delta: float) -> void:
	if (trackingPosition):
		currentPosition = get_global_mouse_position()
		timeHeld += delta

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

func _on_test_placer_button_down() -> void:
	trackingPosition = true
func _on_test_placer_2_button_down() -> void:
	trackingPosition = true
func _on_test_placer_3_button_down() -> void:
	save_scene_to_file()
	
	
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
	var root = objectList
	
	#var worldManager = load(** world manager scene path **)
	#var worldManagerInstance = worldManager.instantiate()
	#root.add_child(worldManagerInstance)
	
	# Ensure all nested children have their owner set
	_set_owner_recursive(root, root)
	
	# Pack scene
	var new_scene = PackedScene.new()
	var result = new_scene.pack(root)
	if result == OK:
		# Save scene
		var scene_path = "res://savedScenes/new_scene.tscn"
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
		
func snap_position(pos : Vector2) -> Vector2:
	var x = round_to_step(pos.x)
	var y = round_to_step(pos.y)
	return Vector2(x, y)
	
func round_to_step(value) -> int:
	var intMultiplier = value / stepSize
	return round(intMultiplier) * stepSize

func place_block(instance):
	var placePos = camera.position
	if (timeHeld >= holdTime):
		placePos = currentPosition
	
	testBlockList.add_child(instance)
	instance.position = snap_position(placePos)
	
	currentBlock = instance
	trackingPosition = false
	currentPosition = camera.position
	timeHeld = 0.0

func _on_block_button_button_up() -> void:
	var blockInstance = testBlock.instantiate()
	place_block(blockInstance)
func _on_action_button_button_up() -> void:
	var actionInstance = actionIndicator.instantiate()
	place_block(actionInstance)
