class_name BaseObject
extends Node2D
var blockType = ""
var index = 0
#should turn this into an array
var sprite 
var isDragging = false
var spriteNode = null
var spriteParent = null
var curAreaDragging = null
var curAreaDraggingParent = null
var curArea = null
var index1 = 0
@onready var childrenList = self.get_child(0).get_children()


var size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	var spriteNode = Sprite2D.new()
	spriteNode.visible = false
	spriteNode.modulate.a = 0.5
	#loop through teh scenen 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			curAreaDragging = str(areaParent.name)+"/"+str(areaName)
			curArea = str(areaName)
			spriteNode = self.get_child(0).get_node(str(areaParent.name)+"/Sprite2D").duplicate()
			#TODO i dont want to add this everytime
			self.add_child(spriteNode)
			get_parent().get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType,curAreaDragging)
			self.get_parent().get_parent().get_parent().setTrackingPosition(true)
			isDragging = true
			print("mouse pressed")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.get_parent().get_parent().get_parent().currentBlock and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		print("mouse released")
		#for objects with multiple area2ds 
		#have to rework this ugh
		print("cur area dragging: ", curAreaDragging)
		print("nodes children ", self.get_child(0).get_child(0).get_children())
		
		self.get_child(0).get_node(curAreaDragging).get_parent().global_position= self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		#if self.get_child(0).get_node(curAreaDragging).get_parent().offset:
			#self.get_child(0).get_node(curAreaDragging).get_parent().global_position.x -= self.get_child(0).get_node(curAreaDragging).get_parent().offset
		self.get_node(curArea).global_position =  self.get_child(0).get_node(curAreaDragging).get_parent().global_position
		print("after zip placed: ", self.get_child(0).get_node(curAreaDragging).get_parent().global_position )
		#self.get_parent().get_parent().get_parent().reset_drag_tracking()
		isDragging = false
		
func setArea2D():
	#for zipline do a more specific node traversal for zipline
	var nameIndex = 0
	for blockChild in childrenList:
		var newArea = blockChild.get_node("Area2D").duplicate()
		blockChild.get_node("Area2D").name = "EditorArea"+str(nameIndex)
		newArea.name = "EditorArea"+str(nameIndex)
		nameIndex+=1
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name, blockChild))
		
		
