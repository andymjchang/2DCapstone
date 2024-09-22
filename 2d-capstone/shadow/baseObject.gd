class_name BaseObject
extends Node2D
var blockType = ""
var index = 0
var spritePath = ""

var size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("clicking")
		get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType)
		
func setArea2D():
	var newArea = self.get_child(0).get_node("Area2D").duplicate()
	newArea.name = "EditorArea"
	self.add_child(newArea)
	#print(get_node("Area2D")s)
	newArea.connect("input_event",  _on_area_2d_input_event)

func temp () -> void:
	print("shadow look here: ",self.get_child(0).get_node("Area2D"))
	var newArea = self.get_child(0).get_node("Area2D").duplicate()
	self.add_child(newArea)
	
	newArea.connect("input_event",  _on_area_2d_input_event)
