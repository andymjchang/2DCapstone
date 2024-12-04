extends CanvasLayer

@onready var helpWindow = $HelpWindow
@onready var desc = $HelpWindow/Description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_exited() -> void:
	helpWindow.hide()
	pass # Replace with function body.

func getPosition(tgt):
	if tgt.global_position.y <= get_viewport().size.y/4:
	#	print("Upper half")
		return tgt.global_position + Vector2(0, 150)
	#print("Lower half")
	return tgt.global_position - Vector2(0, 300)

func formatText(toFormat):
	return "[center]" + toFormat + "[/center]"

########################################################################################
### UTILITY ############################################################################
########################################################################################

func _on_play_level_button_mouse_entered():
	helpWindow.position = getPosition($FileButtons/playLevelButton)
	helpWindow.show()
	desc.text = formatText("[i]DEBUG ONLY[/i]\n\nPlays the level from the level editor")
	print("Play button entered")

func _on_save_button_mouse_entered() -> void:
	helpWindow.position = getPosition($FileButtons/saveButton)
	helpWindow.show()
	desc.text = formatText("\n\nSaves the level's data to its file")

func _on_file_button_mouse_entered() -> void:
	helpWindow.position = getPosition($FileButtons/saveButton)
	helpWindow.show()
	desc.text = formatText("\n\nOpens a level file via an entered name")

func _on_help_button_mouse_entered() -> void:
	helpWindow.position = getPosition($FileButtons/saveButton)
	helpWindow.show()
	desc.text = formatText("\n\nClick me for help!")

func _on_keybind_button_mouse_entered():
	helpWindow.position = getPosition($FileButtons/saveButton)
	helpWindow.show()
	desc.text = formatText("\nShows the keyboard shortcuts for certain commands")

########################################################################################
### TOP ROW ############################################################################
########################################################################################

func _on_goal_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/coinButton)
	helpWindow.show()
	desc.text = formatText("[u]Goal[/u]\n When the player reaches this item, the level ends")

func _on_jump_boost_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/coinButton)
	helpWindow.show()
	desc.text = formatText("[u]Jump boost[/u]\n When the player collides with this object, they are propelled upward")

func _on_coin_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/coinButton)
	helpWindow.show()
	desc.text = formatText("[u]Coin[/u]\n Player collect these to increase their score")

func _on_powerup_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Powerup[/u]\n Randomly spawns a powerup that grants invulnerability, heals, speeds up the level, or slows down the level")

func _on_enemy_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Enemy[/u]\n A regular enemy that dies in one successful hit, spawns with an action indicator attached")

func _on_mash_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Mash enemy[/u]\n A special type of enemy the player must mash keys from start (green) to end (red)")

func _on_hold_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Hold enemy[/u]\n A special type of enemy the player must hold punch from start (green) to end (red)")


########################################################################################
### BOTTOM ROW #########################################################################
########################################################################################

func _on_block_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/coinButton)
	helpWindow.show()
	desc.text = formatText("[u]Block[/u]\n Basic block type, these are used to create the ground of a level")

func _on_action_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/coinButton)
	helpWindow.show()
	desc.text = formatText("[u]Action indicator[/u]\n Circular indicators that tell the player when to interact to the beat of the song")

func _on_rac_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/coinButton)
	helpWindow.show()
	desc.text = formatText("[u]Spawn player[/u]\n Changes the spawn location of the player character")

func _on_slide_wall_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Slide wall[/u]\n A narrow wall the player can slide under.")

func _on_p_1_checkpoint_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Checkpoint[/u]\n Allows the player to reset the level starting at the nearest placed checkpoint")

func _on_kill_floor_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Kill floor[/u]\n Floor hazards to require the player to make certain jumps or traverse across gaps")

func _on_breakable_wall_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Breakable wall[/u]\n A large wall the player must punch to get through")

func _on_zipline_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Zipline[/u]\n When the player collides with a zipline, they will be carried from start (green) to end (red)")

func _on_loop_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/powerupButton)
	helpWindow.show()
	desc.text = formatText("[u]Loop[/u]\n Any portion of the level contained within this item's bounds (green to red) is looped 3 times")


########################################################################################
### TOOLBAR ############################################################################
########################################################################################

func _on_p_1_placer_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/jumpBoostButton)
	helpWindow.position.y -= 50
	helpWindow.position.x += 50
	helpWindow.show()
	desc.text = formatText("[i]DEBUG ONLY[/i]\n [u]Custom start[/u]\n Can place the player to spawn at any location in the level")

func _on_mass_move_button_mouse_entered() -> void:
	helpWindow.position = getPosition($objectSelector/BlockButtons/Top/jumpBoostButton)
	helpWindow.position.y -= 25
	helpWindow.position.x += 50
	helpWindow.show()
	desc.text = formatText("[u]Select[/u]\n Select multiple objects in the level editor")


