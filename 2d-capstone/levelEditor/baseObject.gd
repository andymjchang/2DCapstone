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
	timePlaced = Globals.time
	set_process_input(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if block is being dragged, have a transparent image of it follow the mouse around
	if isDragging:
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
	pass
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int, areaName, areaParent) -> void:
	if "player" not in blockType:
		if event.is_action_pressed("click") and checkOrder():
			print("click! on base object - ", self)
			self.get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType,curAreaDragging)
			if clickResult:
			#this will be the path to area2d given that we have the scene object
				curAreaDragging = str(areaParent.name)+"/"+str(areaName)
				curArea = str(areaName)
				
				spriteNode = self.get_child(0).get_node(str(areaParent.name)+"/Sprite2D").duplicate()
				#TODO i dont want to add everytime
				#object has been clicked, so need to tell the level-edito to switch its current block
				#self.get_parent().get_parent().get_parent().emit_signal("objectClicked")
				
				self.get_parent().get_parent().get_parent().setTrackingPosition(true)
				isDragging = true
			print("mouse pressed")
	
	#when the player releases the mouse, set the scene object to that new position
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.get_parent().get_parent().get_parent().currentBlock and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		print("mouse released")
		self.get_child(0).get_node(curAreaDragging).get_parent().global_position= self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		timePlaced = Globals.time
		#for scenes that have multiple components, and offset from the origin for subsqeuent components has to be accounted for
		#if self.get_child(0).get_node(curAreaDragging).get_parent().offset:
			#self.get_child(0).get_node(curAreaDragging).get_parent().global_position.x -= self.get_child(0).get_node(curAreaDragging).get_parent().offset
			#PROBLEM this is not setting the actual object within the scene
		#self.get_node(curArea).global_position =  self.get_child(0).get_node(curAreaDragging).get_parent().global_position
		isDragging = false
		
		
#attaches area2Ds to the base object as well as enables them to detect being clicked on
func setArea2D():
	var nameIndex = 0
	#given a scene object, go through all of its individual major components
	for blockChild in childrenList:
		#grab each compents area2d
		var newArea = blockChild.get_node("Area2D")
		blockChild.get_node("Area2D").name = "EditorArea"+str(nameIndex)
		#give them each a unique name
		newArea.name = "EditorArea"+str(nameIndex)
		nameIndex+=1
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name, blockChild))
		newArea.connect("area_shape_entered", _onBodyEntered)
		newArea.connect("area_shape_exited", _onBodyExited)
		
func _setClickResult(result) -> void:
	clickResult = result
	
func _onBodyEntered(area_rid:RID, area:Area2D, area_shape_index:int, local_shape_index:int) -> void:
	#add all overlapping blocks to array
	#on default theres two overlaps - discount these for now
	#each block collision starts with editorarea0 and is a twofer
	overlappingBlocks.append(area)
	print("me -> ", self.get_child(0).name)
	print("my overlapping blocks! -> ", overlappingBlocks)
	
func _onBodyExited(area_rid:RID, area:Area2D, area_shape_index:int, local_shape_index:int) -> void:
	#if block not overlapping anymore, remove from array
	print("overlapping blocks before delete, ", overlappingBlocks)
	#do I have to delete two things? 
	print("area deleting: ", area.get_parent().get_parent().get_parent().timePlaced)
	overlappingBlocks.erase(area)
	
	print("overlapping blocks after delete, ", overlappingBlocks)
	
		
func checkOrder() -> bool:
	for block in overlappingBlocks:
		if block.get_parent().get_parent().get_parent().timePlaced < self.timePlaced:
			#overlapping block was placed earlier, it is selected 
			return false
	return true
