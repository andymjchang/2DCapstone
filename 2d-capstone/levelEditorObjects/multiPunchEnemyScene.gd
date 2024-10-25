extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var xMove = 30.0
	for actionIndicator in self.get_children():
		if actionIndicator.name != "enemy":
			actionIndicator.global_position.x += xMove
			xMove += 30.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
