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

@onready var vinyl: Sprite2D = $Vinyl

var current_option: int = 2
var options_count: int = MenuOptions.size()

func _ready() -> void:
	update_selection()

func _input(event: InputEvent) -> void:
	if !visible:
		return
	if event.is_action_pressed("jump"):
		current_option = (current_option - 1 + options_count) % options_count
		update_selection()
	if event.is_action_pressed("slide"):
		current_option = (current_option + 1) % options_count
		update_selection()
	if event.is_action_pressed("ui_accept"):
		select_current_option()

func update_selection() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(vinyl, "rotation_degrees", 
		vinyl_rotations[current_option], rotation_tween_duration)

func select_current_option() -> void:
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
	get_tree().paused = false
	self.visible = false
	Globals.paused = false
	self.get_parent().get_parent().music.stream_paused = false
	self.get_parent().get_parent().adaptiveMusic.stream_paused = false

func _onCheckpointButtonUp() -> void:
	# Globals.relocateToCheckpoint = true
	# Globals.inLevel = false
	# Globals.paused = false
	# Engine.time_scale = 1.0
	# get_tree().reload_current_scene()
	_onRestartButtonUp()

func _onRestartButtonUp() -> void:
	Globals.relocateToCheckpoint = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	Globals.paused = false
	get_tree().reload_current_scene()

func _onMainMenuButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	Globals.paused = false
	Globals.time = 0.0
	Globals.FadeTransition("res://ui/landingPage.tscn")


func _onOptionsButtonUp() -> void:
	get_tree().paused = false
	Globals.FadeTransition("res://ui/options.tscn")
	Engine.time_scale = 1.0
	Globals.paused = false
	self.get_parent().get_parent().music.stream_paused = false
