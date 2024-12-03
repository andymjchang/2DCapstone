extends Control

enum MenuOptions {
	RESTART,
	CHECKPOINT,
	RESUME,
	OPTIONS,
	MAIN_MENU
}

@export var vinyl_rotations: Array[float] = [60.0, 30.0, 0.0, -30.0, -60.0]  # Adjust angles as needed
@export var rotation_tween_duration: float = 0.15
@export var slide_in_duration: float = 0.5  # Duration for slide-in animation
@export var slide_offset: float = -1000  # Starting X offset for slide animation

@onready var vinyl: Sprite2D = $Vinyl
@onready var album: Sprite2D = $Album 
@onready var albumBack: Sprite2D = $Back

var current_option: int = 2
var options_count: int = MenuOptions.size()

func _ready() -> void:
	if Globals.inEditor:
		get_node("Vinyl/5/Level2").text = "Exit"
	else:
		get_node("Vinyl/5/Level2").text = "Menu"
	update_selection()

func _input(event: InputEvent) -> void:
	if !visible:
		return
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("jump"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_option = (current_option - 1 + options_count) % options_count
		update_selection()
	elif event.is_action_pressed("slide"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_option = (current_option + 1) % options_count
		update_selection()
	elif event.is_action_pressed("ui_accept"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		select_current_option()

func update_selection() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(vinyl, "rotation_degrees", 
		vinyl_rotations[current_option], rotation_tween_duration)

func select_current_option() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	Globals.paused = false
	match current_option:
		MenuOptions.RESUME:
			_onResumeButtonUp()
		MenuOptions.CHECKPOINT:
			_onCheckpointButtonUp()
		MenuOptions.RESTART:
			_onRestartButtonUp()
		MenuOptions.OPTIONS:
			_onOptionsButtonUp()
		MenuOptions.MAIN_MENU:
			_onMainMenuButtonUp()

func _onResumeButtonUp() -> void:
	self.get_parent().get_parent().music.stream_paused = false
	self.get_parent().get_parent().adaptiveMusic.stream_paused = false
	hide()

func _onCheckpointButtonUp() -> void:
	# Globals.relocateToCheckpoint = true
	# Globals.inLevel = false
	# Globals.paused = false
	# Engine.time_scale = 1.0
	# get_tree().reload_current_scene()
	_onRestartButtonUp()

func _onRestartButtonUp() -> void:
	Globals.relocateToCheckpoint = false
	get_tree().reload_current_scene()

func _onMainMenuButtonUp() -> void:
	Globals.time = 0.0
	if Globals.inEditor:
		Globals.FadeTransition("res://levelEditor/levelEditor.tscn")
	else:
		Globals.FadeTransition("res://ui/landingPage.tscn")



func _onOptionsButtonUp() -> void:
	self.get_parent().get_parent().music.stream_paused = false
	Globals.FadeTransition("res://ui/options.tscn")

func slide_in() -> void:
	# Set initial position off-screen
	vinyl.position.x += slide_offset
	album.position.x += slide_offset
	albumBack.position.x += slide_offset
	# Create tween for slide-in animation
	var tween = create_tween()
	tween.set_parallel(true)  # Animate both nodes simultaneously
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Tween both nodes to their original positions
	tween.tween_property(vinyl, "position:x", 
		vinyl.position.x - slide_offset, slide_in_duration + 0.75)
	tween.tween_property(album, "position:x", 
		album.position.x - slide_offset, slide_in_duration)
	tween.tween_property(albumBack, "position:x",
		albumBack.position.x - slide_offset, slide_in_duration)
