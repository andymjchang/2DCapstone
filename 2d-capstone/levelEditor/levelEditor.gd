extends Node2D


signal objectClicked(instance)
# const values
const measurePixels = 600
const holdTime = 0.15
var lEindex = 0.0

var placedBlocks = []
var currentBlock
var currentPosition : Vector2 = Vector2(450, 450)
var trackingPosition : bool = false
var defaultSpawnPosition = Vector2(450, 450)
var timeHeld = 0.0
var killFDict: Dictionary = {}
var saveFileName 
var isPlaying = false

@export var actionIndicator : PackedScene
@export var checkpoint : PackedScene
@export var platformBlock: PackedScene
@export var enemyCharacter : PackedScene
@export var goalBlock : PackedScene
@export var worldManager : Script
@export var cameraScript : Script
@export var actionManager : Script
@export var killFloorScript : Script
@export var levelUI : PackedScene
@export var player1 : PackedScene
@export var player2 : PackedScene
@export var killFloor : PackedScene
@export var baseObject : PackedScene

@onready var objectList = $objectList
@onready var platformBlocksList = $objectList/platformBlocks
@onready var goalBlocksList = $objectList/goalBlocks
@onready var enemyList = $objectList/enemies
@onready var actionIndicatorsList = $objectList/actionIndicators
@onready var checkpointsList = $objectList/checkpoints
@onready var player1List = $objectList/player1
@onready var player2List = $objectList/player2
@onready var killFloorsList = $objectList/killFloors
@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
@onready var fileLabel = $UI/TextEdit3
@onready var measureLines = $measureLines
@onready var camera = $Camera2D

var bpm : int = 4
var stepSize : int = 150


func _ready():
	self.objectClicked.connect(_onObjectClicked)
	measureLines.beatsPerMeasure = bpm
	measureLines.stepSize = stepSize
	saveFileName = fileLabel.text
	Globals.stepSize = stepSize
	loadLevel()
	
func _process(delta: float) -> void:
	if (trackingPosition):
		currentPosition = get_global_mouse_position()
		timeHeld += delta
	if Input.is_action_just_pressed("click"):
		var mouseCoords = get_global_mouse_position()
		#check to see if we have any objects within those bounds

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
		if currentBlock.blockType == "actionIndicator":
			step = 50
		stepSize = step
		Globals.stepSize = stepSize
		measureLines.stepSize = stepSize
		measureLines.queue_redraw()
		

func loadLevel():
	var content = FileAccess.open("res://levelData/" + saveFileName + ".dat", 1).get_as_text()
	var instanceList = {"platformBlocks": [platformBlock, platformBlocksList], 
		"goalBlocks": [goalBlock, goalBlocksList],
		"killFloors": [killFloor, killFloorsList],
		"actionIndicators": [actionIndicator, actionIndicatorsList], 
		"checkpoints": [checkpoint, checkpointsList], 
		"player1": [player1, player1List],
		"player2": [player2, player2List]}
	var instance
	var instanceParent
	for line in content.split("\n"):
		#print("Current line: ", line)
		if line in instanceList.keys():
			instance = instanceList.get(line)[0]
			instanceParent = instanceList.get(line)[1]
		# Position
		if line.contains(", "):
			var parent = baseObject.instantiate()
			#print("Object: ", instance)
			var instancedObj = instance.instantiate()
			var posPoints = []
			for pos in line.split(", "):
				posPoints.append(pos.to_float())
			instancedObj.position = Vector2(posPoints[0], posPoints[1])
			parent.add_child(instancedObj)
			instanceParent.add_child(parent)

func _on_save_button_down() -> void:
	save_scene_to_file()
	
func _on_text_edit_3_text_changed() -> void:
	saveFileName = fileLabel.text
	
func _on_test_placer_button_down() -> void:
	trackingPosition = true
	
func _on_checkpoint_button_button_up() -> void:
	var checkpointInstance = checkpoint.instantiate()
	var checkParent = baseObject.instantiate()
	checkParent.add_child(checkpointInstance)
	checkParent.blockType = "checkpoint"
	checkpointsList.add_child(checkParent)
	place_block(checkParent, checkpointsList)
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_rac_button_button_up() -> void:
	if !player1List.has_node("baseObject"):
		var player1Instance = player1.instantiate()
		player1Instance.editing = true
		player1Instance.add_to_group("Players")
		var playerParent = baseObject.instantiate()
		playerParent.add_child(player1Instance)
		playerParent.blockType = "player1"
		player1List.add_child(playerParent)
		placeObject(playerParent)
	else:
		currentBlock = player1List.get_node("baseObject").get_node("Player1")
		reset_drag_tracking()

func _on_mouse_button_button_up() -> void:
	if !player2List.has_node("baseObject"):
		var player2Instance = player2.instantiate()
		player2Instance.editing = true
		player2Instance.add_to_group("Players")
		var playerParent = baseObject.instantiate()
		playerParent.add_child(player2Instance)
		playerParent.blockType = "player2"
		player2List.add_child(playerParent)
		placeObject(playerParent)
	else:
		currentBlock = player2List.get_node("baseObject").get_node("Player2")
		reset_drag_tracking()

func _on_play_audio_button_pressed() -> void:
	if not isPlaying:
		objectList.get_node("audio").play()
		get_node("UI").get_node("objectSelector").get_node("playAudioButton").texture_normal = load("res://levelEditor/programmerArtAssets/replayTrack.png")
		isPlaying = true
	else:
		isPlaying = false
		get_node("UI").get_node("objectSelector").get_node("playAudioButton").texture_normal = load("res://levelEditor/programmerArtAssets/playAudio.png")
		objectList.get_node("audio").stop()
		
func placeObject(placedNode):
	placedNode.position = Vector2(450, 450)
	placedNode.setArea2D(placedNode.get_child(0).get_node("Area2D"))
	placedNode.index = lEindex
	lEindex+=1
	currentBlock = placedNode
	
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
	if player1List.get_child_count() == 1 and player2List.get_child_count() == 1:
		var newFile = FileAccess.open("res://levelData/" + saveFileName + ".dat", 7)
		for itemList in objectList.get_children():
			print("Item list: ", itemList.name)
			newFile.store_string(itemList.name + "\n")
			for item in itemList.get_children():
				#newFile.store_string(item.name + "\n")
				newFile.store_string(str(item.position.x) + ", " + str(item.position.y) + "\n")
				print("Storing: ", item.name)
				print("Storing pos: ", str(item.position.x) + ", " + str(item.position.y))
	else:
		print("Unable to save. Need 2 players.")
		
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
		platformBlocksList.add_child(platformBlockInstance)
		platformBlockInstance.position = Vector2(450, 450)
		currentBlock = platformBlockInstance
	if index == 1:
		#put a goal block
		#design question: should we make a list of all the seperate block types?
		var goalBlockInstance = goalBlock.instantiate()
		platformBlocksList.add_child(goalBlockInstance)
		goalBlockInstance.position = Vector2(450, 450)
		currentBlock = goalBlockInstance
	if index ==  2:
		var enemyInstance = enemyCharacter.instantiate()
		enemyList.add_child(enemyInstance)
		enemyInstance.position = Vector2(450, 450)
		currentBlock = enemyInstance
		
#TODO P button should extend currnt block/enemy by one measure
# Q should move the enemy back by one button 
# make the items reclickable
# bind enemies to block, and when bound to a block they should auto snap
	
func startBlockOnNearstBeat(blockInstance):
	var blockX = blockInstance.position.x
	
func snap_position(pos : Vector2) -> Vector2:
	var x = round_to_step(pos.x)
	var y = round_to_step(pos.y)
	
	return Vector2(x, y)
	
func round_to_step(value) -> int:
	var intMultiplier = value / stepSize
	return round(intMultiplier) * stepSize

func place_block(instance, parent):
	var placePos = camera.position
	if (timeHeld >= holdTime):
		placePos = currentPosition
	
	parent.add_child(instance)	
	instance.setArea2D(instance.get_child(0).get_node("Area2D"))
	instance.index = lEindex
	lEindex+=1
	instance.position = snap_position(placePos)
	currentBlock = instance

	_on_text_edit_2_text_changed()
	reset_drag_tracking()

func reset_drag_tracking():
	trackingPosition = false
	currentPosition = camera.position
	timeHeld = 0.0

func _on_block_button_button_up() -> void:
	var blockInstance = platformBlock.instantiate()
	var blockParent = baseObject.instantiate()
	blockParent.add_child(blockInstance)
	blockParent.blockType = "normal"
	place_block(blockParent, platformBlocksList)
func _on_action_button_button_up() -> void:
	var actionInstance = actionIndicator.instantiate()
	var actionParent = baseObject.instantiate()
	actionParent.add_child(actionInstance)
	actionParent.blockType = "actionIndicator"
	place_block(actionParent, actionIndicatorsList)
func _on_goal_button_button_up() -> void:
	var goalInstance = goalBlock.instantiate()
	var goalParent = baseObject.instantiate()
	goalParent.add_child(goalInstance)
	goalParent.blockType = "goalBlock"
	place_block(goalParent, goalBlocksList)
func _on_enemy_button_button_up() -> void:
	var enemyInstance = enemyCharacter.instantiate()
	var enemyParent = baseObject.instantiate()
	enemyParent.add_child(enemyInstance)
	enemyParent.blockType = "enemy"
	place_block(enemyParent, enemyList)
	
func _on_kill_floor_button_button_up() -> void:
	var kfInstance = killFloor.instantiate()
	var kfParent = baseObject.instantiate()
	kfParent.add_child(kfInstance)
	print("button works")
	kfParent.blockType = "killFloor"
	kfParent.temp()
	place_block(kfParent, killFloorsList)


			
func _onObjectClicked(index : int, blockType: String):
	print("Block type: ", blockType)
	var list = getList(blockType).get_children()
	for block in list:
		if block.index == index:
			currentBlock = block
			_on_text_edit_2_text_changed()
			return
	
func getList(blockType : String) -> Node:
	if blockType == "actionIndicator":
		return get_node("objectList/actionIndicatorManager")
	if blockType == "normal":
		return get_node("objectList/platformBlocks")
	if blockType == "enemy":
		return get_node("objectList/players")
	if blockType == "player1":
		return get_node("objectList/player1")
	if blockType == "player2":
		return get_node("objectList/player2")
	if blockType == "goalBlock":
		return get_node("objectList/goalBlocks")
	if blockType == "checkpoint":
		return get_node("objectList/checkpoints")
	if blockType == "killFloor":
		return get_node("objectList/killFloors")
	return null
		
	
		
