extends BaseObject

var activeSprite
var actionIndicators
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	var randIndex = randi_range(0, 1)
	$sprite2D.get_children()[randIndex].visible = true
	activeSprite = 	$sprite2D.get_children()[randIndex]
	self.blockType = "normal"
	

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("click")
		get_parent().get_parent().get_parent().emit_signal("objectClicked",index, blockType)
	pass # Replace with function body.
