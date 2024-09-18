extends Node2D

# const values
const measurePixels = 600
var placedBlocks = []
var currentBlock

@export var testBlock : PackedScene
@export var actionIndicator : PackedScene

#new blocks added
#TODO get rid of enemy block, should just be a normal platform
@export var platformBlock: PackedScene
@export var enemyCharacter : PackedScene
@export var goalBlock : PackedScene


@onready var objectList = $objectList
@onready var testBlockList = $objectList/testBlocks
@onready var platformBlockList = $objectList/platformBlocks
@onready var enemyList = $objectList/enemies
@onready var actionIndicatorList = $objectList/actionIndicators
@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
@onready var measureLines = $measureLines

var bpm : int = 4
var stepSize : int = 150

func _ready():
	measureLines.beatsPerMeasure = bpm
	measureLines.stepSize = stepSize
	Globals.stepSize = stepSize

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
	var blockInstance = testBlock.instantiate()
	testBlockList.add_child(blockInstance)
	blockInstance.position = Vector2(450, 450)
	currentBlock = blockInstance
func _on_test_placer_2_button_down() -> void:
	var actionInstance = actionIndicator.instantiate()
	actionIndicatorList.add_child(actionInstance)
	actionInstance.position = Vector2(450, 450)
	currentBlock = actionInstance
#TODO dlete this haha
func _on_platform_block_button_down() -> void:
	var platformBlockInstance = platformBlock.instantiate()
	platformBlockList.add_child(platformBlockInstance)
	platformBlockInstance.position = Vector2(450, 450)
	currentBlock = platformBlockInstance
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


func _on_block_type_drop_down_item_selected(index: int) -> void:
	#based on this instance
	if index == 0:
		#put a normal block
		var platformBlockInstance = platformBlock.instantiate()
		platformBlockList.add_child(platformBlockInstance)
		platformBlockInstance.position = Vector2(450, 450)
		currentBlock = platformBlockInstance
	if index == 1:
		#put a goal block
		#design question: should we make a list of all the seperate block types?
		var goalBlockInstance = goalBlock.instantiate()
		platformBlockList.add_child(goalBlockInstance)
		goalBlockInstance.position = Vector2(450, 450)
		currentBlock = goalBlockInstance
	if index ==  2:
		print("idk what block to put here")
		
#TODO P button should extend currnt block/enemy by one measure
# Q should move the enemy back by one button 
# make the items reclickable
# bind enemies to block, and when bound to a block they should auto snap
	
func startBlockOnNearstBeat(blockInstance):
	var blockX = blockInstance.position.x
	
