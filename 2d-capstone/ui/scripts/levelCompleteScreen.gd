extends Control
signal updateScoreData()

@onready var music = $jingle
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.updateScoreData.connect(_onUpdateScoreData)
	var audioPath = load("res://audioTracks/CourseComplete_153bpm.mp3") as AudioStream
	music.stream = audioPath
	music.stream.loop = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _onRetryButtonUp() -> void:
	Globals.relocateToCheckpoint = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _onMenuButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://ui/landingPage.tscn")

func _onCheckpointButtonDown() -> void:
	Globals.relocateToCheckpoint = true
	Globals.inLevel = false


func _onCheckpointButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	
func _onUpdateScoreData() -> void:
	$VBoxContainer/perfectLabel.text += " " + str(Globals.numPerfects)
	$VBoxContainer/goodLabel.text += " " + str(Globals.numGoods)
	$VBoxContainer/barelyLabel.text += " " + str(Globals.numBarelys)
	$VBoxContainer/coinsLabel.text += " " + str(Globals.coinsCollected)
	$VBoxContainer/overallPercentageLabel.text += " " + str(Globals.percetageHit)+"%"
	$VBoxContainer/scoreLabel.text += " "+ str(Globals.endScore)

func playMusic() -> void:
	#getting 
	print("getting here23")
	Engine.time_scale = 1.0
	var audioPath = load("res://audioTracks/CourseComplete_153bpm.mp3") as AudioStream
	music.stream = audioPath
	music.stream.loop = false
	music.play()
