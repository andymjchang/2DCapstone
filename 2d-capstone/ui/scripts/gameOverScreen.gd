extends Control
@onready var music = $jingle
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var newAudio = load("res://audioTracks/GameOver_120bpm.mp3") as AudioStream
	music.stream = newAudio
	music.stream.loop = false


func _onRetryButtonUp() -> void:
	Globals.relocateToCheckpoint = false
	Globals.gameOver = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _onMenuButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://ui/landingPage.tscn")
	Globals.gameOver = false

func _onCheckpointButtonDown() -> void:
	Globals.relocateToCheckpoint = true
	Globals.inLevel = false
	Globals.gameOver = false


func _onCheckpointButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	
func playMusic() -> void:
	music.play()
	
