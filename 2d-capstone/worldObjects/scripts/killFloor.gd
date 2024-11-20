extends StaticBody2D

var area
var intersecting = false
var downsize
var curSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	#area = get_node("Area2d")
	get_node("Area2D").body_entered.connect(_onKillFloorBodyEntered)
	downsize = "downsize"
	
	curSprite = get_node("ColorRect").duplicate()
	pass # Replace with function body.
	
func _onKillFloorBodyEntered(body:Node2D):
	if "players" in body.get_groups():
		#print(body, " Entered")
		pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("blocks"):
		intersecting = true
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("blocks"):
		intersecting = false
	elif body.is_in_group("players"):
		#body.emit_signal("takeDamage", 27)
		print("Did i exit: ", body.exitedZip)
		if body.exitedZip:
			get_tree().root.get_node("level").emit_signal("movePlayer", body.zipDest)
		else:
			body.position.x = get_tree().root.get_node("level/Camera2D/ActionLine").global_position.x
			body.position.y = get_tree().root.get_node("level/Camera2D/glitchLines").global_position.y
	pass # Replace with function body.
	
#func temp () -> void:
	#print("shadow look here: ",get_node("Area2D") )
	#self.get_parent().setArea2D(get_node("Area2D").duplicate())
	
