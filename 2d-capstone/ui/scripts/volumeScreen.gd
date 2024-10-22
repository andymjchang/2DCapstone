extends Control

var sound = AudioServer.get_bus_index("Master")
@onready var groupPair = { $sliders/playerSlider : "playerSounds",
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
		var curVolGroup = groupPair[slider]
		for sound in get_tree().get_nodes_in_group(curVolGroup):
			#TODO only really need to do this once
			slider.value = db_to_linear(sound.volume_db)
		#slider.value = db_to_linear(groupPair[slider].volume)

 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _onDragEnd(value, slider) -> void:
	var soundGroup = groupPair[slider]
	for sound in get_tree().get_nodes_in_group(soundGroup):
		sound.volume_db = linear_to_db(value)
	#AudioServer.set_bus_volume_db(sound, linear_to_db(value))


func _onBackButtonUp() -> void:
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/options.tscn")
	else:
		get_tree().current_scene.get_node("LevelUI/Options").visible = true
		self.queue_free()
