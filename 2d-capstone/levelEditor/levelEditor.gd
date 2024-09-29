extends Node2D


signal objectClicked(index : int, blockType: String, curAreaDragging)
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
var levelDataPath = "res://levelData/"
var overwrite = false
var isLoad = true
var blockTypes = ["player1", "player2", "normal", "actionIndicator", "goalBlock", "enemy", "killFloor", "checkpoint", "breakableWall", "zipline"]
enum {PLAYER1, PLAYER2, NORMAL, ACTIONINDICATOR, GOALBLOCK, ENEMY, KILLFLOOR, CHECKPOINT, BREAKABLEWALL, ZIPLINE}
var delete = "deleteBlock"

var MIN_STEP : int = 25

var FILE_EXISTS_PATH = "Level with file name \ndetected. Load?"
var OVERWRITE_FILE = "Overwrite existing\nfile?"
var UNABLE_TO_SAVE = "Unable to save.\nNeed 2 players."

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
@export var breakableWall : PackedScene
@export var zipline : PackedScene


@onready var objectList = $objectList
@onready var platformBlocksList = $objectList/platformBlocks
@onready var goalBlocksList = $objectList/goalBlocks
@onready var enemyList = $objectList/enemies
@onready var actionIndicatorsList = $objectList/actionIndicators
@onready var checkpointsList = $objectList/checkpoints
@onready var bWallsList = $objectList/breakableWalls
@onready var player1List = $objectList/player1
@onready var player2List = $objectList/player2
@onready var killFloorsList = $objectList/killFloors
@onready var ziplineList = $objectList/ziplines
@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
@onready var fileLabel = $UI/TextEdit3
@onready var measureLines = $measureLines
@onready var camera = $Camera2D
@onready var status = $StatusWindow
@onready var levelTemplatePacked = preload("res://worlds/levelTemplate.tscn")

var bpm : int = 4
var stepSize : int = 150
var levelSaved = false


func _ready():
	self.objectClicked.connect(_onObjectClicked)
	measureLines.beatsPerMeasure = bpm
	measureLines.stepSize = stepSize
	saveFileName = fileLabel.text
	Globals.stepSize = stepSize
	if FileAccess.file_exists(levelDataPath + saveFileName + ".dat"):
		displayStatus(FILE_EXISTS_PATH, true)
	
func _process(delta: float) -> void:
	if (trackingPosition):
		currentPosition = get_global_mouse_position()
		timeHeld += delta
	if Input.is_action_just_pressed("click"):
		var mouseCoords = get_global_mouse_position()
		#check to see if we have any objects within those bounds
	if Input.is_action_just_pressed(delete) and currentBlock:
		print("detecting delete key press")
		#get current click on block and delete it 
		var blockList = getList(currentBlock.blockType)
		for block in blockList.get_children():
			if block.index == currentBlock.index:
				#we have found our block, delete
				#blockList.erase(block)
				currentBlock.queue_free()
				currentBlock = null
				break
			

func _on_text_edit_text_changed() -> void:
	if bpmLabel.text.is_valid_int():
		bpm = int(bpmLabel.text)
		measureLines.beatsPerMeasure = bpm
		measureLines.queue_redraw()

func _on_text_edit_2_text_changed() -> void:
	if stepLabel.text.is_valid_int():
		var step = int(stepLabel.text)
		if (step < MIN_STEP):
			step = MIN_STEP
		if currentBlock and currentBlock.blockType == "actionIndicator" or currentBlock.blockType == "enemy":
			step = MIN_STEP
		stepSize = step
		Globals.stepSize = stepSize
		measureLines.stepSize = stepSize
		measureLines.queue_redraw()
		

func loadLevel():
	var content = FileAccess.open("res://levelData/" + saveFileName + ".dat", 1).get_as_text()
	var instanceList = {"platformBlocks": [platformBlock, platformBlocksList, blockTypes[2]], 
		"goalBlocks": [goalBlock, goalBlocksList, blockTypes[4]],
		"killFloors": [killFloor, killFloorsList, blockTypes[6]],
		"actionIndicators": [actionIndicator, actionIndicatorsList, blockTypes[3]], 
		"checkpoints": [checkpoint, checkpointsList, blockTypes[7]], 
		"enemies": [enemyCharacter, enemyList, blockTypes[5]],
		"player1": [player1, player1List, blockTypes[0]],
		"player2": [player2, player2List, blockTypes[1]]}
	var instance
	var objectList
	var blockType = blockTypes[2]
	for line in content.split("\n"):
		if line in instanceList.keys():
			instance = instanceList.get(line)[0]
			objectList = instanceList.get(line)[1]
			blockType = instanceList.get(line)[2]
		# Position
		if line.contains(", "):
			var objectParent = baseObject.instantiate()
			var instancedObj = instance.instantiate()
			var posPoints = []
			for pos in line.split(", "):
				posPoints.append(pos.to_float())

			objectParent.add_child(instancedObj)
			objectParent.blockType = blockType
			place_block(objectParent, objectList, Vector2(posPoints[0], posPoints[1]), true)

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
	checkParent.blockType = blockTypes[7]
	checkpointsList.add_child(checkParent)
	place_block(checkParent, checkpointsList, camera.position, false)
	
func _onZiplineButtonPressed() -> void:
	var ziplineStartInstance = zipline.instantiate()
	var zipParent = baseObject.instantiate()
	zipParent.add_child(ziplineStartInstance)
	zipParent.blockType = blockTypes[9]
	ziplineList.add_child(zipParent)
	place_block(zipParent, ziplineList, camera.position, false)
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_rac_button_button_up() -> void:
	if !player1List.has_node("baseObject"):
		var player1Instance = player1.instantiate()
		#got rid of this beacuse it was causing a bug - if needed we can work it back in
		#player1Instance.editing = true
		player1Instance.add_to_group("Players")
		var playerParent = baseObject.instantiate()
		playerParent.add_child(player1Instance)
		playerParent.blockType = blockTypes[0]
		place_block(playerParent, player1List, camera.position, false)
	else:
		currentBlock = player1List.get_node("baseObject")
		reset_drag_tracking()

func _on_mouse_button_button_up() -> void:
	if !player2List.has_node("baseObject"):
		var player2Instance = player2.instantiate()
		#same deal as with raccoon 
		#player2Instance.editing = true
		player2Instance.add_to_group("Players")
		var playerParent = baseObject.instantiate()
		playerParent.add_child(player2Instance)
		playerParent.blockType = blockTypes[1]
		place_block(playerParent, player2List, camera.position, false)
	else:
		currentBlock = player2List.get_node("baseObject")
		reset_drag_tracking()

#start here
func _on_block_button_button_up() -> void:
	var blockInstance = platformBlock.instantiate()
	var blockParent = baseObject.instantiate()
	blockParent.add_child(blockInstance)
	blockParent.blockType = blockTypes[2]
	place_block(blockParent, platformBlocksList, camera.position, false)

func _on_action_button_button_up() -> void:
	var actionInstance = actionIndicator.instantiate()
	var actionParent = baseObject.instantiate()
	actionParent.add_child(actionInstance)
	actionParent.blockType = blockTypes[3]
	place_block(actionParent, actionIndicatorsList, camera.position, false)


func _on_breakable_wall_button_button_up() -> void:
	var bWallInstance = breakableWall.instantiate()
	var bWallParent = baseObject.instantiate()
	bWallParent.add_child(bWallInstance)
	bWallParent.blockType = blockTypes[8]
	place_block(bWallParent, bWallsList, camera.position, false)

func _on_goal_button_button_up() -> void:
	var goalInstance = goalBlock.instantiate()
	var goalParent = baseObject.instantiate()
	goalParent.add_child(goalInstance)
	goalParent.blockType = blockTypes[4]
	place_block(goalParent, goalBlocksList, camera.position, false)

func _on_enemy_button_button_up() -> void:
	var enemyInstance = enemyCharacter.instantiate()
	var enemyParent = baseObject.instantiate()
	enemyParent.add_child(enemyInstance)
	enemyParent.blockType = blockTypes[5]
	place_block(enemyParent, enemyList, camera.position, false)

func _on_kill_floor_button_button_up() -> void:
	var kfInstance = killFloor.instantiate()
	var kfParent = baseObject.instantiate()
	kfParent.add_child(kfInstance)
	kfParent.blockType = blockTypes[6]
	place_block(kfParent, killFloorsList, camera.position, false)

func _on_play_audio_button_pressed() -> void:
	if not isPlaying:
		camera.get_node("audio").play()
		get_node("UI").get_node("objectSelector").get_node("playAudioButton").texture_normal = load("res://levelEditor/programmerArtAssets/reset_audio.png")
		isPlaying = true
	else:
		isPlaying = false
		get_node("UI").get_node("objectSelector").get_node("playAudioButton").texture_normal = load("res://levelEditor/programmerArtAssets/play_audio.png")
		camera.get_node("audio").stop()
	
func _on_right_button_button_down() -> void:
	if (currentBlock == null or "player" in currentBlock.blockType): return
	currentBlock.position.x += stepSize
func _on_left_button_button_down() -> void:
	if (currentBlock == null or "player" in currentBlock.blockType): return
	currentBlock.position.x -= stepSize
func _on_down_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.y += stepSize
func _on_up_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.y -= stepSize
	
func save_scene_to_file():
	if player1List.get_child_count() == 1 and player2List.get_child_count() == 1:
		if FileAccess.file_exists(levelDataPath + saveFileName + ".dat") and overwrite == false:
			status.show()
			displayStatus(OVERWRITE_FILE, true)
		else:
			# successful save
			var newFile = FileAccess.open("res://levelData/" + saveFileName + ".dat", 7)
			for itemList in objectList.get_children():
				newFile.store_string(itemList.name + "\n")
				for item in itemList.get_children():
					newFile.store_string(str(item.position.x) + ", " + str(item.position.y) + "\n")
	else:
		displayStatus(UNABLE_TO_SAVE, false)
		
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

func place_block(instance, parent, placePos, initial):
	print("I'm being placed")
	if initial:
		instance.position = placePos
	# ? Assume dragging
	# elif (timeHeld >= holdTime):
	# 	placePos = instance.get_child(0).position
	# 	instance.position = snap_position(placePos)
	# Snap default player position
	elif instance.blockType == blockTypes[0]: 
		instance.position.x = 45
		instance.position.y = placePos.y
	elif instance.blockType == blockTypes[1]: 
		instance.position.x = 45
		instance.position.y = placePos.y
	else:
		print("In this one")
		instance.position = snap_position(placePos)
	parent.add_child(instance)	
	
	instance.setArea2D()
	instance.index = lEindex
	lEindex+=1
	currentBlock = instance

	_on_text_edit_2_text_changed()
	reset_drag_tracking()

func reset_drag_tracking():
	trackingPosition = false
	#why is camera null?
	currentPosition = camera.position
	timeHeld = 0.0	

func _onObjectClicked(index : int, blockType: String, curAreaDragging):
	trackingPosition = true
	#timeHeld = 0.0
	print("Reaching signal")
	var list = getList(blockType).get_children()
	for block in list:
		if block.index == index:
			print("Found area: ", curAreaDragging)
			currentBlock = block
			print("current block: ", currentBlock)
			#_on_text_edit_2_text_changed()
			return
	
func getList(blockType : String) -> Node:
	if blockType == "actionIndicator":
		return get_node("objectList/actionIndicators")
	if blockType == "normal":
		return get_node("objectList/platformBlocks")
	if blockType == "enemy":
		return get_node("objectList/enemies")
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
	if blockType == "breakableWall":
		return get_node("objectList/breakableWalls")
	if blockType == "zipline":
		return get_node("objectList/ziplines")
	return null
	
func setTrackingPosition(setVal : bool) -> void:
	trackingPosition = setVal


func _on_audio_progress_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and  event.pressed:
		self.get_node("UI/objectSelector/audioProgress").isDragging=true


func _on_yes_pressed() -> void:
	get_tree().paused = false
	if isLoad:
		# load level message
		loadLevel()
		isLoad = false
	else:
		# overwrite message
		overwrite = true
		save_scene_to_file()
	status.hide()


func _on_no_pressed() -> void:
	get_tree().paused = false
	status.hide()
	isLoad = false

func displayStatus(message, display):
	get_tree().paused = true
	status.show()
	status.get_node("StatusMessage").text = message
	if display:
		# regular confirmation
		status.get_node("Buttons/No").text = "No"
		status.get_node("Buttons/Yes").show()
		status.get_node("Buttons").show()
	else:
		# unable to save message
		status.get_node("Buttons/Yes").hide()
		status.get_node("Buttons/No").text = "Close"

func _on_play_level_button_button_down() -> void:
	save_scene_to_file()
	var scene_instance = levelTemplatePacked.instantiate()
	scene_instance.levelFile = saveFileName
	
	get_tree().paused = false
	
	# Access the current scene and remove it from the scene tree
	#var current_scene = get_tree().current_scene
	#Globals.editorNode = current_scene
	Globals.enablePreviewUI()
	Globals.currentEditorFileName = saveFileName
	get_tree().change_scene_to_file("res://worlds/levelTemplate.tscn")
	#current_scene.visible = false

	# Add the new scene to the scene tree and set it as the current scene
	#get_tree().root.add_child(scene_instance)  # Add new scene instance to the tree
	#get_tree().current_scene = scene_instance  # Set it as the new current scene



	
