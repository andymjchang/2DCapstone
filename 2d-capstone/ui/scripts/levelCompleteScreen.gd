extends Control
signal updateScoreData()

enum MenuOptions {
	NEXT_LEVEL,
	LEVEL_SELECT,
	RESTART
}

@export var vinyl_rotations: Array[float] = [30.0, 0.0, -30.0]  
@export var rotation_tween_duration: float = 0.15
@export var slide_in_duration: float = 0.5  # Duration for slide-in animation
@export var slide_offset: float = -1000  # Starting X offset for slide animation

@onready var jingle = $jingle
@onready var vinyl: Sprite2D = $Vinyl
@onready var album: Sprite2D = $Album 
@onready var albumBack: Sprite2D = $Back  

var current_option: int = 0
var options_count: int = MenuOptions.size()

func _ready() -> void:
	if Globals.inEditor:
		get_node("Vinyl/1/Level1").text = "Level\nEditor"
	else:
		get_node("Vinyl/1/Level1").text = "Level\nSelect"
	self.updateScoreData.connect(_onUpdateScoreData)
	update_selection()

func _input(event: InputEvent) -> void:
	if !visible:
		return
	if event is InputEventMouseMotion:
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
	elif event.is_action_pressed("punch") and Globals.usingController:
		select_current_option()
	elif Input.is_action_pressed("ui_accept"):
		select_current_option()

func update_selection() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(vinyl, "rotation_degrees", 
		vinyl_rotations[current_option], rotation_tween_duration)

func select_current_option() -> void:
	jingle.stop()
	Engine.time_scale = 1.0
	get_tree().paused = false
	Globals.gameOver = false
	match current_option:
		MenuOptions.NEXT_LEVEL:
			var nextLevel = Globals.getNextLevel(Globals.curFile)
			if nextLevel != "":
				Globals.curFile = nextLevel
				Globals.FadeTransition("res://worlds/levelTemplate.tscn")
			else:
				Globals.FadeTransition("res://ui/levelSelect.tscn")
		MenuOptions.LEVEL_SELECT:
			if Globals.inEditor:
				Globals.FadeTransition("res://levelEditor/levelEditor.tscn")
			else:
				Globals.FadeTransition("res://ui/landingPage.tscn")
		MenuOptions.RESTART:
			Globals.relocateToCheckpoint = false
			get_tree().reload_current_scene()

func _onUpdateScoreData() -> void:
	$perfectLabel.text = str(Globals.numPerfects)
	$goodLabel.text = str(Globals.numGoods)
	$barelyLabel.text = str(Globals.numBarelys)
	$coinsLabel.text = str(Globals.coinsCollected)
	$accuracyLabel.text = "%2.2f" % Globals.percentageHit + "%"
	$scoreLabel.text = str(Globals.endScore)

func playMusic() -> void:
	jingle.play(0.0)

func slide_in() -> void:
	# Set initial position off-screen
	vinyl.position.x += slide_offset
	album.position.x += slide_offset
	albumBack.position.x += slide_offset
	
	# Create tween for slide-in animation
	var tween = create_tween()
	if !tween:
		print("Failed to create tween")
		return
		
	print("Setting up tween properties")
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Store tween as variable to ensure it doesn't get garbage collected
	var _vinyl_tween = tween.tween_property(vinyl, "position:x",
		vinyl.position.x - slide_offset, slide_in_duration + 0.75)
	var _album_tween = tween.tween_property(album, "position:x", 
		album.position.x - slide_offset, slide_in_duration)
	var _back_tween = tween.tween_property(albumBack, "position:x",
		albumBack.position.x - slide_offset, slide_in_duration)
	tween.tween_callback(playMusic)
