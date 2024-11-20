extends Control

enum LevelOptions {
	BACK,
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	CUSTOM
}

@export var vinyl_rotations: Array[float] = [30.0, 0.0, -30.0, -60.0, -90.0]  # Adjust these values as needed
@export var rotation_tween_duration: float = 0.15
@export var slide_in_duration: float = 0.5
@export var slide_offset: float = -1000

@onready var vinyl: Sprite2D
var current_option: int = 1
var options_count: int = LevelOptions.size()

func _ready() -> void:
	# Set initial position off-screen
	vinyl = $Vinyl
	vinyl.position.x += slide_offset
	$Album.position.x += slide_offset

	# Create tween for slide-in animation
	var tween = create_tween()
	tween.set_parallel(true)  # Animate both nodes simultaneously
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Tween both nodes to their original positions
	tween.tween_property(vinyl, "position:x", 
		vinyl.position.x - slide_offset, slide_in_duration + 0.75)
	tween.tween_property($Album, "position:x", 
		$Album.position.x - slide_offset, slide_in_duration)

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
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(vinyl, "rotation_degrees", 
		vinyl_rotations[current_option], rotation_tween_duration)
	
	$Album/Level1.visible = false
	$Album/Level2.visible = false
	$Album/Level3.visible = false
	# You can add visual feedback for the current selection here
	match current_option:
		LevelOptions.LEVEL_1:
			$Album/Level1.visible = true
		LevelOptions.LEVEL_2:
			$Album/Level2.visible = true
		LevelOptions.LEVEL_3:
			$Album/Level3.visible = true
		LevelOptions.BACK:
			# Update UI to show Back is selected
			pass

func select_current_option() -> void:
	match current_option:
		LevelOptions.BACK:
			Globals.FadeTransition("res://ui/landingPage.tscn") 		
		LevelOptions.LEVEL_1:
			Globals.curFile = "Level 1"
			Globals.FadeTransition("res://worlds/levelTemplate.tscn")
		LevelOptions.LEVEL_2:
			Globals.curFile = "Level 2"
			Globals.FadeTransition("res://worlds/levelTemplate.tscn")
		LevelOptions.LEVEL_3:
			Globals.curFile = "Level 3"
			Globals.FadeTransition("res://worlds/levelTemplate.tscn")
		LevelOptions.CUSTOM:
			Globals.curFile = "CustomLevel"
			Globals.FadeTransition("res://worlds/levelTemplate.tscn")
