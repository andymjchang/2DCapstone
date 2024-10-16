extends Node2D

var powerType : Globals.powerType

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	powerType = rng.randi_range(0, len(Globals.powerType) - 1)
	$Display.frame = powerType

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onArea2dBodyEntered(body:Node2D) -> void:
	if "players" in body.get_groups():
		body.emit_signal("getPowerup", powerType)
		pass
