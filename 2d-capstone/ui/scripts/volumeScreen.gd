extends Control


var sound = AudioServer.get_bus_index("Master")
var busIndex
@onready var groupPair = { $sliders/playerSlider : "player",
	$sliders/inGameMusicSlider : "levelMusic",
	$sliders/musicSlider : "music"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#button.connect("button_up", _onKeyButtonUp.bind(button.name))
	for slider in $sliders.get_children():
		slider.connect("value_changed",_onDragEnd.bind(slider))
		slider.max_value = 1.0
		slider.step = 0.05
		var curVolGroup = groupPair[slider]
		busIndex = AudioServer.get_bus_index(curVolGroup)
		slider.value = db_to_linear(AudioServer.get_bus_volume_db(busIndex))	

 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _onDragEnd(value, slider) -> void:
	var soundGroup = groupPair[slider]
	busIndex = AudioServer.get_bus_index(soundGroup)
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))



func _onBackButtonUp() -> void:
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/options.tscn")
	else:
		get_tree().current_scene.get_node("LevelUI/Options").visible = true
		self.queue_free()
