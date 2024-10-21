extends Node2D

var jump
var playerContact = false
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jump = "jump"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerContact and Input.is_action_just_pressed(jump):
		player.emit_signal("doubleJump")
		Globals.resetCamera = true
	pass


func _OnArea2dBodyEntered(body:Node2D) -> void:
	print("I am here")
	if "players" in body.get_groups():
		print("Player needs to jump!")
		player = body
		playerContact = true

func _onArea2dBodyExited(body:Node2D) -> void:
	if "players" in body.get_groups():
		print("Opportunity passed")
		player = null
		playerContact = false
