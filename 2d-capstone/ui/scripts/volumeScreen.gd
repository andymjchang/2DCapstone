extends Control

var sound = AudioServer.get_bus_index("Master")
var groupPair = { $sliders/playerSlider : "playerSounds",
	$sliders/objectSlider : "objectSounds",
	$sliders/musicSlider : "musicSounds"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#button.connect("button_up", _onKeyButtonUp.bind(button.name))
	for slider in $sliders.get_children():
		slider.connect("value_changed",_onDragEnd.bind(slider))
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = db_to_linear(sound)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _onDragEnd(value, slider) -> void:
	#var soundGroup = groupPair[slider]
	#for sound in get_tree().get_nodes_in_group(soundGroup):
	#sound.set_bus_volume_db
	AudioServer.set_bus_volume_db(sound, linear_to_db(value))


func _onBackButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/options.tscn")
	get_tree().current_scene.get_node("LevelUI/Options").visible = true
	self.queue_free()
