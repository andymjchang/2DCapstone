class_name BaseObject
extends Node2D
var blockType = ""
var index = 0
var sprite
var isDragging = false

var size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	sprite = self.get_child(0).get_node("Sprite2D").duplicate()
	#print("sprite: ", sprite)
	sprite.modulate.a = 0.5
	self.add_child(sprite)
	sprite.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isDragging:
		#print("is dragging")
		sprite.visible = true
		sprite.global_position = get_global_mouse_position()
	else:
		sprite.visible = false
	pass
	
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if "player" not in blockType:
		if event.is_action_pressed("click"):
			print("clicking")
			get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType)
			self.get_parent().get_parent().get_parent().setTrackingPosition(true)
			isDragging = true

			print("mouse pressed")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and self.index == self.get_parent().get_parent().get_parent().currentBlock.index and isDragging:
		print("mouse released")
		var endPosition = self.get_parent().get_parent().get_parent().currentPosition
		self.position = self.get_parent().get_parent().get_parent().snap_position(get_global_mouse_position())
		self.get_parent().get_parent().get_parent().reset_drag_tracking()
		isDragging = false
		
func setArea2D():
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
