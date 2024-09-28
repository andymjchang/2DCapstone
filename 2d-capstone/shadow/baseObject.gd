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
var temp = null
var index1 = 0


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
		#print("is dragging")
		#need to aceess which sprite we want to do 
		spriteNode.visible = true
		spriteNode.global_position = get_global_mouse_position()
	elif spriteNode:
		spriteNode.visible = false
	pass
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int, areaName, areaParent) -> void:
	if "player" not in blockType:
		if event.is_action_pressed("click"):
			
			print("click!")
			curAreaDragging = str(areaParent.name)+"/"+str(areaName)
			temp = str(areaName)
			spriteNode = self.get_child(0).get_node(str(areaParent.name)+"/Sprite2D").duplicate()
			spriteNode.name = str(index1)
			index1+=1
			#TODO i dont want to add this everytime
			self.add_child(spriteNode)
			print("Sprite Node!! ", spriteNode)
			get_parent().get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType,curAreaDragging)
			self.get_parent().get_parent().get_parent().setTrackingPosition(true)
			isDragging = true
			
			print("mouse pressed")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.get_parent().get_parent().get_parent().currentBlock and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		print("mouse released")
		#for objects with multiple area2ds 
		#have to rework this ugh
		print("before zip placed: ", self.get_child(0).get_node(curAreaDragging).get_parent().global_position )
		print("cur area draggin1: ", self.get_child(0).get_node(curAreaDragging).get_parent())
		print("mouse pos: ",  get_global_mouse_position())
		print("sprite pos: ", self.get_child(0).get_node(curAreaDragging).get_parent().get_node("Sprite2D").global_position)
		self.get_child(0).get_node(curAreaDragging).get_parent().global_position= get_global_mouse_position()
		self.get_child(0).get_node(curAreaDragging).get_parent().global_position= get_global_mouse_position()
		#self.get_child(0).get_node(curAreaDragging).get_parent().global_position= self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		print("self children: ", self.get_node(temp)) 
		self.get_node(temp).global_position =  self.get_child(0).get_node(curAreaDragging).get_parent().global_position
		print("after zip placed: ", self.get_child(0).get_node(curAreaDragging).get_parent().global_position )
		#self.get_parent().get_parent().get_parent().reset_drag_tracking()
		print("cur area draggin: ", curAreaDragging)
		isDragging = false
		
func setArea2D():
	#for zipline do a more specific node traversal for zipline
	if self.blockType == "zipline":
		# add signals for start
		#elf.get_child(0).get_node("Start/Area2D").connect("input_event",  _on_area_2d_input_event.bind(self.get_child(0).get_node("Start/Area2D").name))
		var newArea = self.get_child(0).get_node("Start/Area2D").duplicate()
		self.get_child(0).get_node("Start/Area2D").name = "EditorArea1"
		newArea.name = "EditorArea1"
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name, self.get_child(0).get_node("Start")))
		#add signals for end
		var newArea2 = self.get_child(0).get_node("End/Area2D").duplicate()
		self.get_child(0).get_node("End/Area2D").name = "EditorArea2"
		newArea2.name = "EditorArea2"
		self.add_child(newArea2)
		newArea2.connect("input_event",  _on_area_2d_input_event.bind(newArea2.name, self.get_child(0).get_node("End")))
	else:
		print("should not be making it here")
		var newArea = self.get_child(0).get_node("Area2D").duplicate()
		newArea.name = "EditorArea"
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event)
