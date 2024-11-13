extends Control
signal updateScoreData()

enum MenuOptions {
	LEVEL_SELECT,
	RESTART
}

@export var vinyl_rotations: Array[float] = [0.0, -30.0]  # Adjust these values as needed
@export var rotation_tween_duration: float = 0.15

@onready var jingle = $jingle
@onready var vinyl: Sprite2D

var current_option: int = 0
var options_count: int = MenuOptions.size()

func _ready() -> void:
	self.updateScoreData.connect(_onUpdateScoreData)
	vinyl = $Vinyl  # Make sure to add a Vinyl node in the scene
	update_selection()

func _input(event: InputEvent) -> void:
	if !visible:
		return
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

func select_current_option() -> void:
	match current_option:
		MenuOptions.LEVEL_SELECT:
			Engine.time_scale = 1.0
			Globals.FadeTransition("res://ui/levelSelect.tscn")
			Globals.gameOver = false
		MenuOptions.RESTART:
			Globals.relocateToCheckpoint = false
			Engine.time_scale = 1.0
			get_tree().reload_current_scene()
			Globals.gameOver = false

func _onUpdateScoreData() -> void:
	$perfectLabel.text += " " + str(Globals.numPerfects)
	$goodLabel.text += " " + str(Globals.numGoods)
	$barelyLabel.text += " " + str(Globals.numBarelys)
	$coinsLabel.text += " " + str(Globals.coinsCollected)
	$overallPercentageLabel.text += " " + "%2.2f" % Globals.percentageHit + "%"
	$scoreLabel.text += " "+ str(Globals.endScore)

func playMusic() -> void:
	jingle.play()
