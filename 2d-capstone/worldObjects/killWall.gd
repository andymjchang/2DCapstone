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
	#if Globals.inLevel:
		#position.x += SPEED * delta
	pass
	
func _onKillWallBodyEntered(body:Node2D):
	if "players" in body.get_groups(): #and Globals.inLevel:	
		print(body, " Entered")
		body.emit_signal("takeDamage", 10)
		#body.position.x += self.position.x + 45
		get_parent().get_parent().emit_signal("resetPosition", body)
