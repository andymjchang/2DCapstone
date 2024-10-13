extends Node2D

@export var powerType : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onArea2dBodyEntered(body:Node2D) -> void:
	if "players" in body.get_groups():
		body.emit_signal("getPowerUp", powerType)
		pass
