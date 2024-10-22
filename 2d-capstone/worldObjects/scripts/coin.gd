extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _onArea2dBodyEntered(body:Node2D) -> void:
	if "players" in body.get_groups():
		print("Player got a coin!")
		body.emit_signal("getCoin")
		self.queue_free()