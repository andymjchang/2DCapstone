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

@export var testBlock : PackedScene
@export var actionIndicator : PackedScene
@export var checkpoint : PackedScene
@export var platformBlock: PackedScene
@export var enemyCharacter : PackedScene
@export var goalBlock : PackedScene
@export var worldManager : Script
@export var levelUI : PackedScene
@export var player1 : PackedScene
@export var player2 : PackedScene
@export var killFloor : PackedScene




@onready var objectList = $objectList
@onready var testBlockList = $objectList/testBlocks
@onready var platformBlockList = $objectList/platformBlocks
@onready var enemyList = $objectList/enemies
@onready var actionIndicatorList = $objectList/actionIndicators
@onready var checkpointList = $objectList/checkpoints
@onready var playerList = $objectList/players
@onready var killFloorList = $objectList/killFloors
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
		stepSize = step
		Globals.stepSize = stepSize
		measureLines.stepSize = stepSize
		measureLines.queue_redraw()
		
func _on_save_button_down() -> void:
	save_scene_to_file()
	
func _on_text_edit_3_text_changed() -> void:
	saveFileName = fileLabel.text

func _on_test_placer_button_down() -> void:
	trackingPosition = true


func _on_checkpoint_button_button_up() -> void:
	var checkpointInstance = checkpoint.instantiate()
	place_block(checkpointInstance, checkpointList)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_rac_button_button_up() -> void:
	if !playerList.has_node("Player1"):
		var player1Instance = player1.instantiate()
		player1Instance.editing = true
		player1Instance.add_to_group("Players")
		playerList.add_child(player1Instance)
		placeObject(player1Instance)
	else:
		currentBlock = playerList.get_node("Player1")
		reset_drag_tracking()

func _on_mouse_button_button_up() -> void:
	if !playerList.has_node("Player2"):
		var player2Instance = player2.instantiate()
		player2Instance.editing = true
		player2Instance.add_to_group("Players")
		playerList.add_child(player2Instance)
		placeObject(player2Instance)
	else:
		currentBlock = playerList.get_node("Player2")
		reset_drag_tracking()


func placeObject(placedNode):
	placedNode.position = Vector2(450, 450)
	currentBlock = placedNode

	
	
	
	
func _on_right_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.x += stepSize
	#killFDict[currentBlock].position.x += stepSize
func _on_left_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.x -= stepSize
	killFDict[currentBlock].position.x -= stepSize
func _on_down_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.y += stepSize
	killFDict[currentBlock].position.y += stepSize
func _on_up_button_button_down() -> void:
	if (currentBlock == null): return
	currentBlock.position.y -= stepSize
	killFDict[currentBlock].position.y -= stepSize

	
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
	instance.index = lEindex
	lEindex+=1
	instance.position = snap_position(placePos)
	#now add a kill floor right below it
	var blockBounds = instance.activeSprite.texture.get_size()*instance.scale/2
	var upperLeftCorner = (instance.position - (blockBounds))/2
	var lowerRightCorner = (instance.position + (blockBounds))/2
	
	#kfloor deets
	var kFloorInstance = killFloor.instantiate()
	killFloorList.add_child(kFloorInstance)
	var kFloorBounds = kFloorInstance as RectangleShape2D
	var kUpperLeftCorner = instance.position - blockBounds
	var kLowerRightCorner = instance.position + blockBounds
	print(upperLeftCorner.y )
	print(lowerRightCorner.y)
	var moveDown = instance.position.y + abs(upperLeftCorner.y - lowerRightCorner.y)/10
	print(blockBounds.y)
	kFloorInstance.position = Vector2(instance.position.x,moveDown)
	print("Pos ", kFloorInstance.position)
	print("Pos ", instance.position)
	currentBlock = instance
	killFDict[instance] = kFloorInstance
	print("placed node type: ", currentBlock)
	reset_drag_tracking()

func reset_drag_tracking():
	trackingPosition = false
	currentPosition = camera.position
	timeHeld = 0.0

func _on_block_button_button_up() -> void:
	var blockInstance = testBlock.instantiate()
	place_block(blockInstance, testBlockList)
func _on_action_button_button_up() -> void:
	var actionInstance = actionIndicator.instantiate()
	place_block(actionInstance, actionIndicatorList)
func _on_goal_button_button_up() -> void:
	var goalInstance = goalBlock.instantiate()
	place_block(goalInstance, testBlockList)
func _on_enemy_button_button_up() -> void:
	var enemyInstance = enemyCharacter.instantiate()
	place_block(enemyInstance, testBlockList)

func checkIntersection():
	for block in killFDict.keys():
		print("made it here")
		var kf = killFDict[block]
	#	if kf.intersecting:
			#kf.scale /= 1.001
			
func _onObjectClicked(index : int):
	print("made it here",index)

	var list = get_node("objectList/testBlocks").get_children()
	print("list ", list)
	for block in list:
		if block.index == index:
			currentBlock = block
			return
	
		
