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
	pass
	#if "players" in body.get_groups(): #and Globals.inLevel:	
		#body.emit_signal("takeDamage", 9)
		#body.position.x = get_tree().root.get_node("level/Camera2D/ActionLine").global_position.x
		#body.position.y = get_tree().root.get_node("level/Camera2D/glitchLines").global_position.y
		##get_parent().get_parent().emit_signal("resetPosition", body)


func _onArea2DBodyEntered(body: Node2D) -> void:
	if "players" in body.get_groups(): #and Globals.inLevel:	
		body.emit_signal("takeDamage", 9)
		body.position.x = get_tree().root.get_node("level/Camera2D/ActionLine").global_position.x
		body.position.y = get_tree().root.get_node("level/Camera2D/glitchLines").global_position.y
		
