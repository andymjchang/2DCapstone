class_name BaseObject
extends Node2D
var blockType = ""
var index = 0
#should turn this into an array
var sprite 
var isDragging = false
var spriteIndex = -1


var size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	#cant do this for zipline
	var spriteList = Node2D.new()
	spriteList.name = "spriteList"
	self.add_child(spriteList)
	if blockType == "zipline":
		sprite = self.get_child(0).get_node("Start/Sprite2D").duplicate()
		sprite.modulate.a = 0.5
		sprite.visible = false
		get_node("spriteList").add_child(sprite)
		sprite = self.get_child(0).get_node("End/Sprite2D").duplicate()
		sprite.modulate.a = 0.5
		sprite.visible = false
		self.get_node("spriteList").add_child(sprite)
	else:
		sprite = self.get_child(0).get_node("Sprite2D").duplicate()
		sprite.modulate.a = 0.5
		self.get_node("spriteList").add_child(sprite)
		sprite.visible = false
	
	#loop through teh scenen 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isDragging:
		#print("is dragging")
		#need to aceess which sprite we want to do 
		sprite.visible = true
		sprite.global_position = get_global_mouse_position()
	else:
		sprite.visible = false
	pass
	
func _setName(areaName) -> void:
	print("area name ", areaName)
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int, areaName) -> void:
	if "player" not in blockType:
		if event.is_action_pressed("click"):
			#do this for zipline change later
			#have to loop through the area2ds
			print("clicking")
			print("area name, ",areaName)
			spriteIndex = self.get_index()	
			
	
			get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType)
			self.get_parent().get_parent().get_parent().setTrackingPosition(true)
			isDragging = true
			
			print("mouse pressed")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.get_parent().get_parent().get_parent().currentBlock and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		print("mouse released")
		#for objects with multiple area2ds 
		var endPosition = self.get_parent().get_parent().get_parent().currentPosition
		self.position = self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		self.get_parent().get_parent().get_parent().reset_drag_tracking()
		isDragging = false
		
func setArea2D():
	#for zipline do a more specific node traversal for zipline
	if self.blockType == "zipline":
		# add signals for start
		#elf.get_child(0).get_node("Start/Area2D").connect("input_event",  _on_area_2d_input_event.bind(self.get_child(0).get_node("Start/Area2D").name))
		var newArea = self.get_child(0).get_node("Start/Area2D").duplicate()
		newArea.name = "EditorArea1"
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name))
		#add signals for end
		var newArea2 = self.get_child(0).get_node("End/Area2D").duplicate()
		newArea2.name = "EditorArea2"
		self.add_child(newArea2)
		newArea2.connect("input_event",  _on_area_2d_input_event.bind(newArea2.name))
		print("after zipline set area 2d has been called", self.get_children())
	else:
		var newArea = self.get_child(0).get_node("Area2D").duplicate()
		newArea.name = "EditorArea"
		self.add_child(newArea)
		newArea.connect("input_event",  _on_area_2d_input_event)
		#print("object type: ",self)
		#print("its children: ", self.get_children())


func temp () -> void:
	var newArea = self.get_child(0).get_node("Area2D").duplicate()
	self.add_child(newArea)
	
	newArea.connect("input_event",  _on_area_2d_input_event)
