extends Control

enum MenuOptions {
	KEY_BINDINGS,
	CALIBRATION,
	VOLUME,
	BACK,
}

@export var vinyl_rotations: Array[float] = [0.0, -32.7, -61.7, -89.2]

var current_option: int = 0
var options_count: int = MenuOptions.size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_selection()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		current_option = (current_option - 1 + options_count) % options_count
		update_selection()
	elif event.is_action_pressed("slide"):
		current_option = (current_option + 1) % options_count
		update_selection()
	elif event.is_action_pressed("ui_accept"):
		select_current_option()

func update_selection() -> void:
	reset_options()
	
	$OptionsMenuVinyl.rotation_degrees = vinyl_rotations[current_option]
	
	match current_option:
		MenuOptions.KEY_BINDINGS:
			pass
		MenuOptions.CALIBRATION:
			pass
		MenuOptions.VOLUME:
			$VolumeScreen.visible = true
		MenuOptions.BACK:
			pass

func select_current_option() -> void:
	match current_option:
		MenuOptions.KEY_BINDINGS:
			_onKeyBindingsButtonUp()
		MenuOptions.CALIBRATION:
			pass
		MenuOptions.VOLUME:
			_onVolumeButtonUp()
		MenuOptions.BACK:
			_onBackButtonUp()

func reset_options() -> void:
	$VolumeScreen.visible = false

func _onKeyBindingsButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/keybindings.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/keybindings.tscn")
	else:
		var kbScene = load("res://ui/keybindings.tscn")
		var kbInstance = kbScene.instantiate()
		get_tree().current_scene.get_node("LevelUI").add_child(kbInstance)
		self.visible = false

func _onBackButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/pauseScreen.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/landingPage.tscn")
	else:
		get_tree().current_scene.get_node("LevelUI/PauseScreen").visible = true
		self.queue_free()

func _onVolumeButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/volumeScreen.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/volumeScreen.tscn")
	else:
		var volumeScene = load("res://ui/volumeScreen.tscn")
		var volumeInstance = volumeScene.instantiate()
		get_tree().current_scene.get_node("LevelUI").add_child(volumeInstance)
		self.visible = false
