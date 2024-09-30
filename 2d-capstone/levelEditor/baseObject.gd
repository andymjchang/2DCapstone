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


var size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if block is being dragged, have a transparent image of it follow the mouse around
	if isDragging:
		spriteNode.visible = true
		spriteNode.modulate.a = 0.5
		spriteNode.global_position = get_global_mouse_position()
	elif spriteNode:
		spriteNode.visible = false
	pass
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int, areaName, areaParent) -> void:
	if "player" not in blockType:
		if event.is_action_pressed("click"):
			print("click!")
			#this will be the path to area2d given that we have the scene object
			curAreaDragging = str(areaParent.name)+"/"+str(areaName)
			curArea = str(areaName)
			
			spriteNode = self.get_child(0).get_node(str(areaParent.name)+"/Sprite2D").duplicate()
			self.add_child(spriteNode)
			#TODO i dont want to add everytime
			#object has been clicked, so need to tell the level-edito to switch its current block
			#self.get_parent().get_parent().get_parent().emit_signal("objectClicked")
			self.get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType,curAreaDragging)
			self.get_parent().get_parent().get_parent().setTrackingPosition(true)
			isDragging = true
			print("mouse pressed")
	
	#when the player releases the mouse, set the scene object to that new position
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.get_parent().get_parent().get_parent().currentBlock and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		self.position = self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		isDragging = false
		
		
#attaches area2Ds to the base object as well as enables them to detect being clicked on
func setArea2D():
	var nameIndex = 0
	#given a scene object, go through all of its individual major components
	for blockChild in childrenList:
		#grab each compents area2d
		var newArea = blockChild.get_node("Area2D").duplicate()
		blockChild.get_node("Area2D").name = "EditorArea"+str(nameIndex)
		#give them each a unique name
		newArea.name = "EditorArea"+str(nameIndex)
		nameIndex+=1
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name, blockChild))
		
		
