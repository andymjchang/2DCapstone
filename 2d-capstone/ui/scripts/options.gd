extends Control

signal keybindSet(val)

enum MenuOptions {
	KEY_BINDINGS,
	CALIBRATION,
	VOLUME,
	BACK,
}

@export var vinyl_rotations: Array[float] = [0.0, -30, -60, -90]
@export var rotation_tween_duration: float = 0.15  # Duration in seconds
@export var slide_in_duration: float = 0.5  # Duration for slide-in animation
@export var slide_offset: float = -1000  # Starting X offset for slide animation

var current_option: int = 0
var options_count: int = MenuOptions.size()

var allowSelect = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect signals
	keybindSet.connect(_onKeyBindSet)
	# Set initial position off-screen
	$OptionsMenuVinyl.position.x += slide_offset
	$Album.position.x += slide_offset
	
	# Create tween for slide-in animation
	var tween = create_tween()
	tween.set_parallel(true)  # Animate both nodes simultaneously
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Tween both nodes to their original positions
	tween.tween_property($OptionsMenuVinyl, "position:x", 
		$OptionsMenuVinyl.position.x - slide_offset, slide_in_duration + 0.75)
	tween.tween_property($Album, "position:x", 
		$Album.position.x - slide_offset, slide_in_duration)
	
	update_selection()
func _process(delta: float) -> void:
	if allowSelect:
		if Input.is_action_just_pressed("ui_up"):
			current_option = wrapi(current_option - 1, 0, MenuOptions.size())
			update_selection()
		elif  Input.is_action_just_pressed("ui_down"):
			current_option = wrapi(current_option + 1, 0, MenuOptions.size())
			update_selection()
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
			select_current_option()

func _input(event: InputEvent) -> void:
	pass
	#if allowSelect:
		#if event is InputEventMouseMotion:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#elif Input.is_action_just_pressed("ui_up"):
			#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#current_option = wrapi(current_option - 1, 0, MenuOptions.size())
			#current_option = (current_option - 1) % options_count
			#update_selection()
		#elif  Input.is_action_just_pressed("ui_down"):
			#
			#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#current_option = (current_option ) % options_count
			#update_selection()
		#elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
			#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#select_current_option()

#func controllerNavigate(val):
	#if $Keybindings.visible:
		#$Keybindings.controllerNavigate(val)
	
	
func _onKeyBindSet(val):
	print("setting select: ", val)
	allowSelect = val
	
func update_selection() -> void:
	Globals.emit_signal("playMove")
	# Create tween for smooth rotation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($OptionsMenuVinyl, "rotation_degrees", 
		vinyl_rotations[current_option], rotation_tween_duration)
	
	match current_option:
		MenuOptions.KEY_BINDINGS:
			pass
		MenuOptions.CALIBRATION:
			pass
		MenuOptions.VOLUME:
			pass
		MenuOptions.BACK:
			pass

func select_current_option() -> void:
	reset_options()
	Globals.emit_signal("playSelect")
	match current_option:
		MenuOptions.KEY_BINDINGS:
			$Keybindings.visible = true
		MenuOptions.CALIBRATION:
			Globals.FadeTransition("res://worlds/calibration.tscn")
		MenuOptions.VOLUME:
			$VolumeScreen.visible = true
		MenuOptions.BACK:
			_onBackButtonUp()


func reset_options() -> void:
	$VolumeScreen.visible = false
	$Keybindings.visible = false
	$Title2.visible = false
func _onKeyBindingsButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/keybindings.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		Globals.FadeTransition("res://ui/keybindings.tscn")
	else:
		var kbScene = load("res://ui/keybindings.tscn")
		var kbInstance = kbScene.instantiate()
		get_tree().current_scene.get_node("LevelUI").add_child(kbInstance)
		self.visible = false

func _onBackButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/pauseScreen.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		Globals.FadeTransition("res://ui/landingPage.tscn")
	else:
		get_tree().current_scene.get_node("LevelUI/PauseScreen").visible = true
		self.queue_free()

func _onVolumeButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/volumeScreen.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		Globals.FadeTransition("res://ui/volumeScreen.tscn")
	else:
		var volumeScene = load("res://ui/volumeScreen.tscn")
		var volumeInstance = volumeScene.instantiate()
		get_tree().current_scene.get_node("LevelUI").add_child(volumeInstance)
		self.visible = false
