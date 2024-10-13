extends StaticBody2D

const SPEED = 300
var area
# Called when the node enters the scene tree for the first time.
func _ready():
	#area = get_node("Area2d")
	get_node("Area2D").body_entered.connect(_onKillWallBodyEntered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _onKillWallBodyEntered(body:Node2D):
	if "players" in body.get_groups(): #and Globals.inLevel:	
		body.emit_signal("takeDamage", 9)
		body.velocity.x += Globals.pixelsPerFrame + 2000
		#get_parent().get_parent().emit_signal("resetPosition", body)
