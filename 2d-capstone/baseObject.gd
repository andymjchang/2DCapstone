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
	
#Resize collision shape per node
func resizeCollision(newSize: float):
	print("not done")
	
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("click")
		get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType)
