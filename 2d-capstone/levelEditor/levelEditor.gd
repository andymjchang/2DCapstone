extends Node2D


signal objectClicked(index : int, blockType: String, curAreaDragging)
signal setMassMove(val : bool)
# const values
const measurePixels = 600
const holdTime = 0.15
var lEindex = 0.0

var maxMin = []
var placedBlocks = []
var currentBlock
var currentPosition : Vector2 = Vector2(450, 450)
var trackingPosition : bool = false
var defaultSpawnPosition = Vector2(450, 450)
var timeHeld = 0.0
var killFDict: Dictionary = {}
var saveFileName = null
var isPlaying = false
var levelDataPath = "res://levelData/"
var overwrite = false
var isLoad = true
var blockTypes = ["player1", "powerup", "normal", "actionIndicator", "goalBlock", "enemy", "killFloor", "p1checkpoint", "p2checkpoint", "breakableWall", "zipline", "placer", "slideWall", "jumpBoost", "coin", "keyBinding", "skip", "mash", "hold", "moveLine", "loop"]
enum {PLAYER1, PLAYER2, NORMAL, ACTIONINDICATOR, GOALBLOCK, ENEMY, KILLFLOOR, CHECKPOINT, BREAKABLEWALL, ZIPLINE, PLACER}
var delete = "deleteBlock"
var bindedBlocks = []
var isBinding = false
var turnOffSnap = false
var massMove = false
var editingFile = false

var MIN_STEP : int = 25

var FILE_EXISTS_PATH = "Level with file name \ndetected. Load?"
var OVERWRITE_FILE = "Overwrite existing\nfile?"
var NEED_PLAYER = "Unable to save.\nNeed 1 player."
var UNABLE_TO_SAVE = "No file name found.\nEnter a name using\n the file button."

@export var p1Placer : PackedScene
@export var p2Placer : PackedScene
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
@export var killFloor : PackedScene
@export var baseObject : PackedScene
@export var breakableWall : PackedScene
@export var zipline : PackedScene
@export var slideWall : PackedScene 
@export var powerup : PackedScene
@export var jumpBoost : PackedScene
@export var coin : PackedScene
@export var keyBinding : PackedScene
@export var skip : PackedScene
@export var mash : PackedScene
@export var hold : PackedScene
@export var moveLine : PackedScene
@export var loop : PackedScene

#block variants list
@onready var enemyType = {"enemy" : enemyCharacter, "slide" : enemyCharacter}
@onready var platformType = ["rustic", "city"]
@onready var instructionType = ["punch", "slide", "jump", "activate"]
@onready var gameObjectType = {"p1checkpoint" : checkpoint, "goalBlock": goalBlock, "powerup":powerup, "actionIndicator":actionIndicator, "killFloor":killFloor, "breakableWall": breakableWall, "zipline": zipline, "slideWall": slideWall, "jumpBoost": jumpBoost, "coin":coin}

@onready var typeArrays = { "enemyType" : ["enemy", "slideEnemy"],
							"platformType" : ["rustic", "city"],
							"instructionType" : ["punch", "slide", "jump", "activate"],
							"gameObjectType" : {"p1checkpoint" : checkpoint, "goalBlock": goalBlock, "powerup":powerup, "actionIndicator":actionIndicator, "killFloor":killFloor, "breakableWall": breakableWall, "zipline": zipline, "slideWall": slideWall, "jumpBoost": jumpBoost, "coin":coin, "skip":skip, "loop":loop} }
#var blockTypes = ["player1", "powerup", "normal", "actionIndicator", "goalBlock", "enemy", "killFloor", "p1checkpoint", "p2checkpoint", "breakableWall", "zipline", "placer", "slideWall", "jumpBoost", "coin", "keyBinding", "multiPunch"]
@onready var typeMap = {blockTypes[1]: "gameObjectType",
						blockTypes[2]: "platformType",
						blockTypes[3]: "gameObjectType",
						blockTypes[4]: "gameObjectType",
						blockTypes[5]: "enemyType",
						blockTypes[6]: "gameObjectType",
						blockTypes[7]: "gameObjectType",
						blockTypes[9]: "gameObjectType",
						blockTypes[10]: "gameObjectType",
						blockTypes[12]: "gameObjectType",
						blockTypes[13]: "gameObjectType",
						blockTypes[14]: "gameObjectType",
						blockTypes[15]: "instructionType",
						blockTypes[16]: "gameObjectType",
						blockTypes[20]: "gameObjectType"}

var listMap = {"powerup" : powerupList , "actionIndicator" : actionIndicatorsList, "goalBlock" : goalBlocksList, "enemy" : enemyList, "killFloor" : killFloorsList, "p1checkpoint": p1checkpointsList, "breakableWall" : bWallsList, "zipline": ziplineList,  "slideWall": slideWallList, "jumpBoost": 	jumpList, "coin": coinList, "keyBinding": keyBindingList, "skip": skipList, "mash": mashList, "hold": holdList}


@onready var objectList = $objectList
@onready var platformBlocksList = $objectList/platformBlocks
@onready var goalBlocksList = $objectList/goalBlocks
@onready var enemyList = $objectList/enemies
@onready var actionIndicatorsList = $objectList/actionIndicators
@onready var p1checkpointsList = $objectList/playerCheckpoints
@onready var bWallsList = $objectList/breakableWalls
@onready var player1List = $objectList/player
@onready var killFloorsList = $objectList/killFloors
@onready var beatsMinLabel = $UI/TextEdit0
@onready var ziplineList = $objectList/ziplines
@onready var breakableWallList = $objectList/breakableWalls
@onready var slideWallList = $objectList/slideWalls
@onready var placerList = $objectList/placers
@onready var powerupList = $objectList/powerups
@onready var jumpList = $objectList/jumpBoosts
@onready var coinList = $objectList/coins
@onready var keyBindingList = $objectList/keyBindings
@onready var skipList = $objectList/skips
@onready var mashList = $objectList/mashes
@onready var holdList = $objectList/holds
@onready var moveLineList = $objectList/moveLines
@onready var loopList = $objectList/loops
@onready var onboarding = $Onboarding


@onready var bpmLabel = $UI/TextEdit
@onready var stepLabel = $UI/TextEdit2
@onready var measureLines = $measureLines
@onready var camera = $Camera2D
@onready var status = $StatusWindow
@onready var levelTemplatePacked = preload("res://worlds/levelTemplate.tscn")
@onready var currentFile = $UI/CurrentFile

var bpm : int = 4
var beatsMin : int = 120
var stepSize : int = 150
var levelSaved = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.inEditor = true
	listMap = {"powerup" : powerupList , "actionIndicator" : actionIndicatorsList, "goalBlock" : goalBlocksList, "enemy" : enemyList, "killFloor" : killFloorsList, "p1checkpoint": p1checkpointsList, "breakableWall" : bWallsList, "zipline": ziplineList,  "slideWall": slideWallList, "jumpBoost": 	jumpList, "coin": coinList, "keyBinding": keyBindingList, "skip": skipList, "mash": mashList, "hold": holdList}
	Globals.customStart = false
	Globals.levelEditorTime = 0.0
	#set signals
	self.objectClicked.connect(_onObjectClicked)
	self.setMassMove.connect(_onSetMassMove)
	measureLines.beatsPerMeasure = bpm
	measureLines.stepSize = stepSize
	if Globals.curFile == "":
		# saveFileName = fileLabel.text
		Globals.curFile = saveFileName

	if beatsMinLabel.text.is_valid_int():
		beatsMin = int(beatsMinLabel.text)
		Globals.setBPM(beatsMin)
	
	Globals.stepSize = stepSize
	
func _process(delta: float) -> void:
	#if (trackingPosition):
		#currentPosition = get_global_mouse_position()
		#timeHeld += delta
	updateTime(delta)
	
	if not editingFile:
		if Input.is_action_just_pressed("tab"):
			#we want to go through the list of objects for current block
			#TODO add binded block functionality later
			if !isBinding and currentBlock:
				#grab the list of similiar types
				#TODO add a check here to see if this is a valid grab
				var curTypeName = typeMap[currentBlock.blockType]
				var curTypeList = typeArrays[curTypeName]
				currentBlock.tabType(curTypeList, curTypeName, listMap)
		if Input.is_action_just_pressed("click"):
			var mouseCoords = get_global_mouse_position()
			#check to see if we have any objects within those bounds
		if Input.is_action_just_pressed(delete) and currentBlock:
			#get current click on block and delete it 
			var blockList = getList(currentBlock.blockType)
			for block in blockList.get_children():
				if block.index == currentBlock.index:
					#we have found our block, delete
					currentBlock.queue_free()
					currentBlock = null
					break
					
			if !massMove:
				for block in bindedBlocks:
					block.queue_free()
			else:
				emit_signal("_onSetMassMove", null, false)
		#TODO make sure that pressing l while typing in name doesnt mess anything up 
		if Input.is_action_just_pressed("lengthenBlock") and currentBlock and currentBlock.blockType == "normal":
			#extend platform block by one platform block
			lengthenPlatform()
		if Input.is_action_just_pressed("bindBlocks"):
			if isBinding:
				isBinding = false
				bindedBlocks = []
			else:
				isBinding = true

func _on_text_edit_0_text_changed(new_text) -> void:
	if beatsMinLabel.text.is_valid_int():
		beatsMin = int(beatsMinLabel.text)
		Globals.setBPM(beatsMin)

func _on_text_edit_text_changed(new_text) -> void:
	if bpmLabel.text.is_valid_int():
		bpm = int(bpmLabel.text)
		measureLines.beatsPerMeasure = bpm
		measureLines.queue_redraw()

func _on_text_edit_2_text_changed(new_text) -> void:
	if stepLabel.text.is_valid_int():
		var step = int(stepLabel.text)
		if (step < MIN_STEP):
			step = MIN_STEP
		stepSize = step
		Globals.stepSize = stepSize
		measureLines.stepSize = stepSize
		
func updateTime(delta: float):
	Globals.levelEditorTime = Globals.levelEditorTime + delta

func clearLevel():
	for objList in $objectList.get_children():
		for child in objList.get_children():
			child.queue_free()

func loadLevel():
	print("save file name, ", saveFileName)
	clearLevel()

	var content = FileAccess.open("res://levelData/" + saveFileName + ".dat", 1).get_as_text()
	var instanceList = {"platformBlocks": [platformBlock, platformBlocksList, blockTypes[2]], 
		"goalBlocks": [goalBlock, goalBlocksList, blockTypes[4]],
		"killFloors": [killFloor, killFloorsList, blockTypes[6]],
		"actionIndicators": [actionIndicator, actionIndicatorsList, blockTypes[3]], 
		"playerCheckpoints": [checkpoint, p1checkpointsList, blockTypes[7]], 
		"enemies": [enemyCharacter, enemyList, blockTypes[5]],
		"player": [player1, player1List, blockTypes[0]],
		"breakableWalls": [breakableWall,breakableWallList,  blockTypes[9]],
		"ziplines": [zipline, ziplineList, blockTypes[10]],
		"slideWalls": [slideWall, slideWallList, blockTypes[12]],
		"powerups": [powerup, powerupList, blockTypes[1]],
		"jumpBoosts": [jumpBoost, jumpList, blockTypes[13]],
		"coins": [coin, coinList, blockTypes[14]],
		"keyBindings":[keyBinding, keyBindingList, blockTypes[15]],
		"skips":[skip, skipList, blockTypes[16]],
		"mashes": [mash, mashList, blockTypes[17]],
		"holds": [hold, holdList, blockTypes[18]],
		"loops": [loop, loopList, blockTypes[20]]}
	var instance
	var objectList
	var blockType = blockTypes[2]
	var loadContent = content.split("\n")
	get_node("UI/TextEdit0").text = loadContent[0]
	for line in loadContent.slice(1):
		if line in instanceList.keys():
			instance = instanceList.get(line)[0]
			objectList = instanceList.get(line)[1]
			#print("List: ", objectList)
			blockType = instanceList.get(line)[2]
		# Position
		if line.contains(", "):
			var objectParent = baseObject.instantiate()
			var instancedObj = instance.instantiate()
			var posPoints = []
			for pos in line.split(", "):
				pos = pos.replace(",", "")
				if pos.is_valid_float():
					posPoints.append(pos.to_float())
				else:
					posPoints.append(pos)
			objectParent.add_child(instancedObj)
			objectParent.blockType = blockType
			place_block(objectParent, objectList, Vector2(posPoints[0], posPoints[1]), true)
			#TODO just turn this into the load 
			objectParent.setComponents(posPoints)
			objectParent.setTileMaps(posPoints)		
			objectParent.setImage(posPoints)	
			#this should be the onl call in the future 
			#objectParent.load(posPoints)
			#do this if object has more than one component

func _on_save_button_down() -> void:
	if saveFileName:
		save_scene_to_file()
	else:
		status.show()
		displayStatus(UNABLE_TO_SAVE, false)

	
func _on_file_button_pressed() -> void:
	editingFile = true
	setFileLoad()
	
func _on_test_placer_button_down() -> void:
	trackingPosition = true

func _on_p_1_placer_button_button_up() -> void:
	Globals.customStart = true
	var placerInstance = p1Placer.instantiate()
	var placerParent = baseObject.instantiate()
	placerParent.add_child(placerInstance)
	placerParent.blockType = blockTypes[11]
	placerList.add_child(placerInstance)
	place_block(placerParent, placerList, camera.position, false)
	#might need to change this to the editor area
	Globals.startP1Coords = placerParent.get_child(0).get_node("Player1/EditorArea1").global_position

func _on_p1checkpoint_button_pressed() -> void:
	var checkpointInstance = checkpoint.instantiate()
	var checkParent = baseObject.instantiate()
	checkParent.add_child(checkpointInstance)
	checkParent.blockType = blockTypes[7]
	p1checkpointsList.add_child(checkParent)
	place_block(checkParent, p1checkpointsList, camera.position, false)

func _onKeyBindingButtonUp() -> void:
	var kbInstance = keyBinding.instantiate()
	var kbParent = baseObject.instantiate()
	kbParent.add_child(kbInstance)
	kbParent.blockType = blockTypes[15]
	keyBindingList.add_child(kbParent)
	place_block(kbParent, keyBindingList, camera.position, false)

func _onZiplineButtonPressed() -> void:
	var ziplineInstance = zipline.instantiate()
	var zipParent = baseObject.instantiate()
	zipParent.add_child(ziplineInstance)
	zipParent.blockType = blockTypes[9]
	ziplineList.add_child(zipParent)
	place_block(zipParent, ziplineList, camera.position, false)
	
func _onLoopButtonPressed() -> void:
	var loopInstance = loop.instantiate()
	var loopParent = baseObject.instantiate()
	loopParent.add_child(loopInstance)
	loopParent.blockType = blockTypes[9]
	loopList.add_child(loopParent)
	place_block(loopParent, loopList, camera.position, false)
	
func _onSlideWallButtonUp() -> void:
	var slideWallInstance = slideWall.instantiate()
	var slideWallParent = baseObject.instantiate()
	slideWallParent.add_child(slideWallInstance)
	slideWallParent.blockType = blockTypes[12]
	slideWallList.add_child(slideWallParent)
	place_block(slideWallParent, slideWallList, camera.position, false)

func _on_exit_button_pressed() -> void:
	Globals.inEditor = false
	# This will be the final functionality so players can navigate between menus
	get_tree().change_scene_to_file("res://ui/landingPage.tscn")

	# For debugging
	# get_tree().quit()

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

#start here
func _on_block_button_button_up() -> void:
	
	#load("res://levelEditorObjects/platformBlockScene.tscn")
	var whuh = load("res://levelEditorObjects/platformBlockScene.tscn").duplicate()
	var blockParent = baseObject.instantiate()
	blockParent.index = lEindex
	var blockInstance = whuh.duplicate(true).instantiate()
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
	bWallParent.blockType = blockTypes[9]
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

func _onPowerupButtonPressed() -> void:
	var powerInstance = powerup.instantiate()
	var powerParent = baseObject.instantiate()
	powerParent.add_child(powerInstance)
	powerParent.blockType = blockTypes[1]
	place_block(powerParent, powerupList, camera.position, false)

func _onJumpBoostButtonPressed() -> void:
	var jumpInstance = jumpBoost.instantiate()
	var jumpParent = baseObject.instantiate()
	jumpParent.add_child(jumpInstance)
	jumpParent.blockType = blockTypes[13]
	place_block(jumpParent, jumpList, camera.position, false)

func _onCoinButtonPressed() -> void:
	var coinInstance = coin.instantiate()
	var coinParent = baseObject.instantiate()
	coinParent.add_child(coinInstance)
	coinParent.blockType = blockTypes[14]
	place_block(coinParent, coinList, camera.position, false)

#TODO change every button down to this
func _onButtonDown(instanceType, list, blockType, val) -> void:
	var objectInstance = instanceType.instantiate()
	var instanceParent = baseObject.instantiate()
	instanceParent.add_child(objectInstance)
	instanceParent.blockType = blockType
	place_block(instanceParent, list,camera.position, val)
	
func _onSkipButtonUp() -> void:
	_onButtonDown(skip, skipList, blockTypes[16], false)
func _onMashButtonUp() -> void:
	_onButtonDown(mash, mashList, blockTypes[17], false)
func _onHoldButtonUp() -> void:
	_onButtonDown(hold, holdList, blockTypes[18], false)
func _onMassMoveButtonUp() -> void:
	_onButtonDown(moveLine, moveLineList, blockTypes[19], false)

	
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
	if(isBinding or massMove):
		for block in bindedBlocks:
			block.position.x += stepSize
	else:
		currentBlock.position.x += stepSize
	
func _on_left_button_button_down() -> void:
	if (currentBlock == null or "player" in currentBlock.blockType): return	
	if(isBinding or massMove):
		for block in bindedBlocks:
			block.position.x -= stepSize
	else:
		currentBlock.position.x -= stepSize
func _on_down_button_button_down() -> void:
	if (currentBlock == null): return
	if(isBinding or massMove):
		for block in bindedBlocks:
			block.position.y += stepSize
	else:
		currentBlock.position.y += stepSize
func _on_up_button_button_down() -> void:
	if (currentBlock == null): return
	if(isBinding or massMove):
		for block in bindedBlocks:
			block.position.y -= stepSize
	else:
		currentBlock.position.y -= stepSize
	
func save_scene_to_file():
	if player1List.get_child_count() == 1:
		if FileAccess.file_exists(levelDataPath + saveFileName + ".dat") and overwrite == false:
			status.show()
			displayStatus(OVERWRITE_FILE, true)
		else:
			overwrite = false
			# successful save
			var newFile = FileAccess.open("res://levelData/" + saveFileName + ".dat", 7)
			newFile.store_string(get_node("UI/TextEdit0").text + "\n")
			for itemList in objectList.get_children():
				newFile.store_string(itemList.name + "\n")
				if itemList.name !=  "placers" or itemList.name !=  "moveLines":
					for item in itemList.get_children():
						#go through each of the items children areas
						var childrenList = item.get_child(0).get_children()
						var index = 0
						var editorName = "EditorArea"+str(index)
						var posChain = ""
						#go through all of the individual block components
						#TODO deligate this to the children not here
						for blockChild in childrenList:
							#saving for platfrom block differs since their size varies#
							#TODO I dont want to do this, delegate this work to the child class
							if itemList.name == "platformBlocks":
								#save the number of cols as well as the extents so we know where to start drawing	
								posChain = str(blockChild.global_position.x) + ", " + str(blockChild.global_position.y)+", "+str(blockChild.get_parent().numCols) + ", " + str(blockChild.get_parent().extents)+ ", "+str(blockChild.get_parent().newPos)+ ", "
							elif itemList.name == "keyBindings":
								posChain = str(blockChild.global_position.x) + ", " + str(blockChild.global_position.y)+", "+ str(blockChild.get_parent().instructionType)+", "
							elif itemList.name == "enemies":
								posChain = str(blockChild.global_position.x) + ", " + str(blockChild.global_position.y)+", "+ str(blockChild.get_parent().enemyType)+", "
							elif itemList.name == "mashes":
								posChain = item.save()
							else:
								posChain = posChain + str(blockChild.get_node(editorName).global_position.x) + ", " + str(blockChild.get_node(editorName).global_position.y) + ", "
							index+=1
							editorName = "EditorArea"+str(index)
						#print("child list in save, ", childrenList)
						posChain = posChain.substr(0, posChain.length()-1)
						posChain += "\n"
						newFile.store_string(posChain)
	else:
		displayStatus(NEED_PLAYER, false)
		
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
	#print("I'm being placed")
	
	if initial:
		instance.position = placePos
	# ? Assume dragging
	# elif (timeHeld >= holdTime):
	# 	placePos = instance.get_child(0).position
	# 	instance.position = snap_position(placePos)
	# Snap default player position
	elif instance.blockType == blockTypes[0]: 
		instance.position.x = 0
		instance.position.y = placePos.y
	elif !turnOffSnap:
		instance.position = snap_position(placePos)
	else:
		instance.position = placePos
		turnOffSnap = false
	#print("list: ", parent, "instance:", instance.get_child(0))
	parent.add_child(instance)	
	
	instance.setArea2D()
	instance.index = lEindex
	lEindex+=1
	currentBlock = instance

	if currentBlock.blockType == blockTypes[19]:
		emit_signal("setMassMove", instance.get_child(0).getStartEndPos(), true)
	if massMove and currentBlock.blockType != blockTypes[19]:
		emit_signal("setMassMove", null, false)
		
	_on_text_edit_2_text_changed(10)
	reset_drag_tracking()

func reset_drag_tracking():
	trackingPosition = false
	#why is camera null?
	currentPosition = camera.position
	timeHeld = 0.0	

func _onObjectClicked(index : int, blockType: String, curAreaDragging):
	trackingPosition = true
	var list = getList(blockType).get_children()
	for block in list:
		if block.index == index:
			if(isBinding):
				#add to the current list of binded blocks
				bindedBlocks.append(block)
			else:
				currentBlock = block
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
	if blockType == "goalBlock":
		return get_node("objectList/goalBlocks")
	if blockType == "p1checkpoint":
		return get_node("objectList/playerCheckpoints")
	if blockType == "killFloor":
		return get_node("objectList/killFloors")
	if blockType == "breakableWall":
		return get_node("objectList/breakableWalls")
	if blockType == "zipline":
		return get_node("objectList/ziplines")
	if blockType == "loop":
		return get_node("objectList/loops")
	if blockType == "placer":
		return get_node("objectList/placers")
	if blockType == "slideWall":
		return get_node("objectList/slideWalls")
	if blockType == "powerup":
		return get_node("objectList/powerups")
	if blockType == "jumpBoost":
		return get_node("objectList/jumpBoosts")
	if blockType == "coin":
		return get_node("objectList/coins")
	if blockType == "keyBinding":
		return get_node("objectList/keyBindings")
	if blockType == "skip":
		return get_node("objectList/skips")
	if blockType == "mash":
		return get_node("objectList/mashes")
	if blockType == "hold": 
		return get_node("objectList/holds")
	if blockType == "moveLine":
		return get_node("objectList/moveLines")
	return null
	
func setTrackingPosition(setVal : bool) -> void:
	trackingPosition = setVal


func _on_audio_progress_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		self.get_node("UI/objectSelector/audioProgress").isDragging=true


func _on_yes_pressed() -> void:
	get_tree().paused = false
	# overwrite message
	print("Setting overwrite")
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
	status.get_node("Buttons").show()
	if display:
		# regular confirmation
		status.get_node("Buttons/No").text = "No"
		status.get_node("Buttons/Yes").show()
		status.get_node("Buttons").show()
	else:
		# unable to save message
		status.get_node("Buttons/Yes").hide()
		status.get_node("Buttons/No").text = "Close"

func setFileLoad():
	$UI/FileLoadMode.show()


func _on_load_file_pressed() -> void:
	$UI/FileLoadMode/StatusMessage.text = "Enter a file name."
	var tgtFile = $UI/FileLoadMode/FileName.text
	print("Tgt:" , tgtFile)
	# if "tutorial" in tgtFile.to_lower() or "level 1" in tgtFile.to_lower() or "level 2" in tgtFile.to_lower() or "level 3" in tgtFile.to_lower():
	# 	$UI/FileLoadMode/StatusMessage.text = "Cannot open file."
	if FileAccess.file_exists(levelDataPath + tgtFile + ".dat"):
		saveFileName = tgtFile
		loadLevel()
		$UI/FileLoadMode.hide()
		editingFile = false
	else:
		saveFileName = tgtFile
		$UI/FileLoadMode.hide()
		clearLevel()
		editingFile = false
	currentFile.text = "Now editing: " + tgtFile + ".dat"

func _on_play_level_button_button_down() -> void:
	if saveFileName:
		save_scene_to_file()
		overwrite = true
		save_scene_to_file()
		# var scene_instance = levelTemplatePacked.instantiate()
		
		get_tree().paused = false
		
		# Access the current scene and remove it from the scene tree
		#var current_scene = get_tree().current_scene
		#Globals.editorNode = current_scene
		Globals.enablePreviewUI()
		Globals.currentEditorFileName = saveFileName
		Globals.curFile = saveFileName
		get_tree().change_scene_to_file("res://worlds/levelTemplate.tscn")
		#Globals.FadeTransition("res://worlds/levelTemplate.tscn")
		#current_scene.visible = false

		# Add the new scene to the scene tree and set it as the current scene
		#get_tree().root.add_child(scene_instance)  # Add new scene instance to the tree
		#get_tree().current_scene = scene_instance  # Set it as the new current scene
	else:
		status.show()
		displayStatus(UNABLE_TO_SAVE, false)

func lengthenPlatform() -> void:
	#this isnt modular but it will work for now TODO
	var blockArea = currentBlock.get_child(0).get_child(0).get_node("EditorArea0")
	#get the lower left and upp right coords of the current block
	var tileWidth = currentBlock.get_child(0).tileWidth
	var defaultWidth = (12.0 * tileWidth)/2.0
	var currentBlockWidth = (currentBlock.get_child(0).numCols * tileWidth)/2.0
	var newXPos = defaultWidth + currentBlockWidth
	newXPos = blockArea.global_position.x + newXPos
	var blockInstance = platformBlock.instantiate()
	var blockParent = baseObject.instantiate()
	blockParent.blockType = blockTypes[2]
	blockParent.add_child(blockInstance)
	turnOffSnap = true
	place_block(blockParent, platformBlocksList, Vector2(newXPos, blockArea.global_position.y), false)
	

func _onSetMassMove(coords, val) -> void:
	#TODO switch this to bind maybe idk
	if !val:
		massMove = false
		bindedBlocks = []
	else:
		#we need to gather all of the blocks to the right of the line
		massMove = true
		isBinding = false
		#just clearing as like a sanity check
		bindedBlocks = []
		print("axis type: ",currentBlock.get_child(0).axisType  )
		if currentBlock.get_child(0).axisType == "vertical":
			bindedBlocks = getAreaChildren(coords, 0)
		else:
			print("horizontal true")
			bindedBlocks = getAreaChildren(coords, 1)

func getAreaChildren(coords, coordType) -> Array:
	
	var xMin = min(coords[0].x, coords[1].x)
	var xMax = max(coords[0].x, coords[1].x)
	var yMin = min(coords[0].y, coords[1].y)
	var yMax = max(coords[0].y, coords[1].y)
	var returnArray = []
	var arrayVec = []
	#var newInstructionType = typeOptions[curIndex+1] if curIndex+1 <= typeOptions.size()-1 else typeOptions[0]
	var coordTypeComplement = 0 if coordType == 1 else 1
	#only do this if the current block is a moveLine
	if currentBlock.blockType == blockTypes[19]:
	#we are making a vertical box, meaning the lines are horizontal
		var minMax = currentBlock.get_child(0).getMaxMin()
		for itemList in $objectList.get_children():
			for item in itemList.get_children():
				#return [start.global_position.y, end.global_position.y, endMinVec.x, endMaxvec.x]
				var pos = item.global_position
				print("coord type: ", coordType, " other coord type: ", coordTypeComplement)
				print("min max array: ", minMax)
				print("coords we are checking: ", pos)
				if  pos[coordType] >= minMax[0] && pos[coordType] <= minMax[1] && pos[coordTypeComplement] >= minMax[2] && pos[coordTypeComplement] <= minMax[3]:
					print("making it inside")
					returnArray.append(item)
	
	
	#we are making a horizontal box, meaning the lines are vertical
		#this is expensive, TODO - look into sorting nodes on insertion
		
		#print("return array: ", returnArray)
	if returnArray.size() == 0.0:
		returnArray.append(currentBlock)
	return returnArray
		
func _on_help_button_pressed():
	editingFile = true
	onboarding.set_display("instruction")

func _on_keybind_button_pressed():
	editingFile = true
	onboarding.set_display("keybindings")