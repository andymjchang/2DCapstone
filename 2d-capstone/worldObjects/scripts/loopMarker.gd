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
	var dist = destination.position - self.position
	get_node("Respawn").scale = Vector2(100, 1)
	pass



func _onArea2dBodyEntered(body:Node2D) -> void:
	print("Entering body: ", body.name)
	if "Player" in body.name:
		if self.name == "LoopMarkerStart":
			print("at start")
			get_parent().emit_signal("recordData")

		elif self.name == "LoopMarkerEnd":
			print("at end")
			var destination = get_parent().get_child(START)
			print("Got dest: ", destination)
			get_parent().emit_signal("resetData", destination)
			#get_tree().root.get_node("level").emit_signal("resetLoop", destination)


func _onRespawnAreaEntered(area:Node2D) -> void:
	#print("Detected item in group: ", area.get_parent().get_parent().get_groups())

	if "enemies" in area.get_parent().get_parent().get_groups():
		get_parent().emit_signal("recordEnemies", area.get_parent().get_parent().global_position)
	pass
