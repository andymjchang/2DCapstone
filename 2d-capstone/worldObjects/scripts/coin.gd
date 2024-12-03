extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _onArea2dBodyEntered(body:Node2D) -> void:
	if "players" in body.get_groups():
		body.emit_signal("getCoin")
		self.queue_free()