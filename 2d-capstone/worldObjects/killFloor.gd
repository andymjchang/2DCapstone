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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _onKillFloorBodyEntered(body:Node2D):
	if "players" in body.get_groups():
		#print(body, " Entered")
		body.emit_signal("takeDamage", 1)
		get_parent().get_parent().get_parent().emit_signal("resetPosition", body)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("blocks"):
		intersecting = true
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("blocks"):
		intersecting = false
	pass # Replace with function body.
	
#func temp () -> void:
	#print("shadow look here: ",get_node("Area2D") )
	#self.get_parent().setArea2D(get_node("Area2D").duplicate())
	
