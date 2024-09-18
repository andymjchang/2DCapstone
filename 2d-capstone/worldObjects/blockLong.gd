extends StaticBody2D

var activeSprite
signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("blocks")
	var randIndex = randi_range(0, 1)
	$sprite2D.get_children()[randIndex].visible = true
	activeSprite = 	$sprite2D.get_children()[randIndex]
	

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
			emit_signal("clicked")
			print("I was clicked")
			

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
		emit_signal("clicked")
		print("I was clicked")


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("I was clicked")
	pass # Replace with function body.
