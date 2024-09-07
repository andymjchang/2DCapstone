extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Area2D").body_entered.connect(_onKillFloorBodyEntered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _onKillFloorBodyEntered(body:Node2D):
	if "players" in body.get_groups():	
		print(body, " Entered")
		body.emit_signal("takeDamage")