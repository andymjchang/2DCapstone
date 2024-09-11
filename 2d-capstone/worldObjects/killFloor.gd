extends StaticBody2D

var area

# Called when the node enters the scene tree for the first time.
func _ready():
	#area = get_node("Area2d")
	get_node("Area2D").body_entered.connect(_onKillFloorBodyEntered)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _onKillFloorBodyEntered(body:Node2D):
	if "players" in body.get_groups():
		print(body, " Entered")
		body.emit_signal("takeDamage", 1)
		get_parent().get_parent().emit_signal("resetPosition", body.name)
