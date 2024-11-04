extends Node2D

var distBetween = Vector2.ZERO
enum {START, END}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var destination = Vector2.ZERO
	if self.name == "LoopMarkerStart":
		destination = get_parent().get_child(START)
	elif self.name == "LoopMarkerEnd":
		destination = get_parent().get_child(END)
	
	pass



func _onArea2dBodyEntered(body:Node2D) -> void:
	print("Entering body: ", body.name)
	if "Player" in body.name:
		if self.name == "LoopMarkerStart":
			print("at start")

		elif self.name == "LoopMarkerEnd":
			print("at end")
			var destination = get_parent().get_child(START)
			print("Got dest: ", destination)
			get_tree().root.get_node("level").emit_signal("resetLoop", destination)



	pass
