class_name BaseObject
extends Node2D
var blockType = ""
var index = 0
var sprite 
var isDragging = false
var spriteNode = null
var spriteParent = null
var curAreaDragging = null
var curAreaDraggingParent = null
var curArea = null
var platformType = "rustic"
var instructionType = "punch"
@onready var childrenList = self.get_child(0).get_children()
var spriteInScene = false

#dont think I need these delete later TODO
signal clickSuccess()
var clickResult = true

var overlappingBlocks = []
var timePlaced

var size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clickSuccess.connect(_setClickResult)
	timePlaced = Globals.levelEditorTime
	set_process_input(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if block is being dragged, have a transparent image of it follow the mouse around
	if isDragging and spriteNode:
		if !spriteInScene:
			#we need to add back the transparent sprite as a child
			self.add_child(spriteNode)
			spriteInScene = true
		spriteNode.visible = true
		spriteNode.modulate.a = 0.5
		spriteNode.global_position = get_global_mouse_position()
	elif spriteNode and spriteNode.is_inside_tree():
		self.remove_child(spriteNode)
		spriteInScene = false
		spriteNode.visible = false
		self.global_position = self.get_child(0).global_position
		
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int, areaName, areaParent) -> void:
	if "player" not in blockType:
		if event.is_action_pressed("click") and checkOrder():
			get_tree().current_scene.emit_signal("objectClicked",index, blockType,curAreaDragging)
			#if clickResult:
			if true:
			#this will be the path to area2d given that we have the scene object
				curAreaDragging = str(areaParent.name)+"/"+str(areaName)
				curArea = str(areaName)
				
				#check if there is a sprite node first 
				if self.get_child(0).has_node(str(areaParent.name)+"/Sprite2D"):
					spriteNode = self.get_child(0).get_node(str(areaParent.name)+"/Sprite2D").duplicate()
					
				self.get_parent().get_parent().get_parent().setTrackingPosition(true)
				isDragging = true
	
	#when the player releases the mouse, set the scene object to that new position
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.get_parent().get_parent().get_parent().currentBlock and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		self.get_child(0).get_node(curAreaDragging).get_parent().global_position= self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		timePlaced = Globals.levelEditorTime
		isDragging = false
		#we do this if theres a mass move line
		if self.blockType == "moveLine":
			get_tree().current_scene.emit_signal("setMassMove", self.get_child(0).get_node(curAreaDragging).get_parent().global_position)
		
		
#attaches area2Ds to the base object as well as enables them to detect being clicked on
func setArea2D():
	var nameIndex = 0
	#given a scene object, go through all of its individual major components
	for blockChild in self.get_child(0).get_children():
		#grab each compents area2d
		var newArea = blockChild.get_node("Area2D")
		
		if blockChild.get_node("Area2D"):
			blockChild.get_node("Area2D").name = "EditorArea"+str(nameIndex)
			#give them each a unique name
			newArea.name = "EditorArea"+str(nameIndex)
			nameIndex+=1
			newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name, blockChild))
			newArea.connect("area_shape_entered", _onBodyEntered)
			newArea.connect("area_shape_exited", _onBodyExited)
		
func _setClickResult(result) -> void:
	clickResult = result
	
func _onBodyEntered(area_rid:RID, area:Area2D, area_shape_index:int, local_shape_index:int) -> void:
	overlappingBlocks.append(area)
	
func _onBodyExited(area_rid:RID, area:Area2D, area_shape_index:int, local_shape_index:int) -> void:
	#if block not overlapping anymore, remove from array
	overlappingBlocks.erase(area)
	
		
func checkOrder() -> bool:
	for block in overlappingBlocks:
		if (!block.get_parent().get_parent().get_parent().is_class("CanvasLayer") and !self.is_class("CanvasLayer") and block.get_parent().get_parent().get_parent().timePlaced > self.timePlaced and !(self.blockType == "normal" and block.get_parent().get_parent().get_parent().blockType == "normal")):
			#verlapping block was placed earlier, it is selected 
			#check how close the pos our to allow manuverbility
			#temp while I implement block click heriarchy that isnt horrible
			return false
			#TODO revist this, reverse the logic
			#if block.get_parent().get_parent().get_parent().blockType == "normal" and abs(block.get_parent().get_parent().get_parent().global_position.x - self.global_position.x) > 500:
				#print("overlapping blocks position: ", block.get_parent().get_parent().get_parent().global_position )
				#print("my position ", self.global_position)
				#print("position subtraction, ",  abs(block.get_parent().get_parent().get_parent().global_position - self.global_position))
				#print("do nothing haha", block.get_children())
				#
				#print("block width -> ")
			#else:
				#return false
	return true
	
func setComponents(posArray : Array) -> void : 
	#given an array of Vector2, 
	#TODO have a safety check so that we dont have a bad access of the array 
	var index = 0
	for block in self.get_child(0).get_children():
		block.global_position.x = posArray[index]
		index+=1
		block.global_position.y = posArray[index]
		index+=1
		
func setTileMaps(posPoints : Array) -> void:
	if blockType == "normal":
		get_child(0).setTileMaps(posPoints)
	pass
	
func setImage(posPoints):
	if get_child(0).has_method("setImage"):
		get_child(0).setImage(posPoints)

func save() -> String:
	if self.get_child(0).has_method("save"):
		return get_child(0).save()
	else:
		#TODO just make this the default way to save
		return ""
		
func load(posPoints) -> void:
	if self.get_child(0).has_method("load"):
		get_child(0).load(posPoints)
	

func tabType(typeOptions, typeName) -> void:
	var curIndex = 0
	var keyList
	var newObjectKey
	var newObject
	if typeName == "platformType":
		#we just want to change the tile map that is active
		
		pass
	elif typeName == "enemyType":
		curIndex = typeOptions.find(self.get_child(0).enemyType)
		var newEnemyType = typeOptions[curIndex+1] if curIndex+1 <= typeOptions.size()-1 else typeOptions[0]
		self.get_child(0).setEnemyType(newEnemyType)
		
	elif typeName == "instructionType":
		curIndex = typeOptions.find(self.get_child(0).instructionType)
		var newInstructionType = typeOptions[curIndex+1] if curIndex+1 <= typeOptions.size()-1 else typeOptions[0]
		self.get_child(0).setInstructionType(newInstructionType)
		#we have the new instruction type 
		pass
	elif typeName == "gameObjectType":
		#get the index of where we are in the list and move forward vy one
		var pos = self.get_child(0).get_child(0).get_node("EditorArea0").global_position
		var currentScene = get_tree().current_scene
		var listToRemoveFrom = currentScene.getList(currentScene.currentBlock.blockType).get_children()
		for block in listToRemoveFrom:
			if block.index == currentScene.currentBlock.index:
				currentScene.getList(currentScene.currentBlock.blockType).get_children().erase(block)
		keyList = typeOptions.keys()
		curIndex = keyList.find(blockType)
		newObjectKey = keyList[curIndex+1] if curIndex+1 <= keyList.size()-1 else keyList[0]
		newObject = typeOptions[newObjectKey].instantiate()
		var listToAddToo = currentScene.getList(newObjectKey)
		currentScene.getList(newObjectKey).add_child(self)
		var removeNode = self.get_child(0)
		self.get_child(0).queue_free()
		self.remove_child(removeNode) 
		self.add_child(newObject)
		self.move_child(newObject, 0)
		blockType = newObjectKey
		currentScene.place_block(self, listToAddToo, pos, false)
		
