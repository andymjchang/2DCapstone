extends Node2D

var powerType : Globals.powerType

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	if self.position.x > 15000:
		powerType = rng.randi_range(2, 3)
	else:
		powerType = rng.randi_range(0, 1)

	if Globals.curFile.begins_with("Tutorial"):
		powerType = Globals.powerType.INVULN
	$Display.play("display")
	$Display.frame = powerType

func _onArea2dBodyEntered(body:Node2D) -> void:
	if "players" in body.get_groups():

		body.emit_signal("getPowerup", powerType)
		$Display.play("poof")
		pass

func _onDisplayAnimationFinished():
	if $Display.animation == "poof":
		$Display.hide()
