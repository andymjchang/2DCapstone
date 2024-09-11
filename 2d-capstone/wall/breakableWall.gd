extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	


	


#func _on_area_2d_entered(body: Node2D) -> void:
	#
		#
	##if len(all_players) > 1:
		##print("wall died")
		##self.visible = false
	##else:
		##body.emit_signal("takeDamage",3)	


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var all_players = get_tree().get_nodes_in_group("players")
	var bothPunching = true
	
	for player in all_players:
		if !player.attack.visible:
			bothPunching = false
			
	if bothPunching:
		self.visible = false
	pass # Replace with function body.
