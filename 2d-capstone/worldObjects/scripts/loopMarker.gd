extends Node2D

var distBetween = Vector2.ZERO
var firstPass = true
enum {START, END}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _onArea2dBodyEntered(body:Node2D) -> void:
	print("Entering body: ", body.name)
	if "Player" in body.name:
		if self.name == "LoopMarkerStart":
			print("at start")
			if firstPass:
				get_parent().emit_signal("recordData")
				firstPass = false
				get_parent().firstPass = false

		elif self.name == "LoopMarkerEnd":
			print("at end")
			var destination = get_parent().get_child(START).get_node("destination")
			print("Got dest: ", destination)
			get_parent().emit_signal("resetData", destination)


func _onRespawnAreaEntered(area:Node2D) -> void:
	print("Detected item in group: ", area.get_parent().get_parent().get_groups())
	if "enemies" in area.get_parent().get_parent().get_groups():
		get_parent().emit_signal("recordEnemies", area.get_parent().get_parent())
	elif "powerup" in area.get_parent().get_groups():
		print("Found a powerup")
		get_parent().emit_signal("recordPowers", area.get_parent())
