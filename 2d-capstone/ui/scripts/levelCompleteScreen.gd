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
@export var slide_offset: float = -1200  # Starting X offset for slide animation

@onready var jingle = $jingle
@onready var vinyl: Sprite2D = $Vinyl
@onready var album: Sprite2D = $Album 
@onready var albumBack: Sprite2D = $Back  

var jingle_played = false
var current_option: int = 0
var options_count: int = MenuOptions.size()
var playerName: String = ""
var playerEntry
var focused = false
func _ready() -> void:
	if Globals.inEditor:
		get_node("Vinyl/1/Level1").text = "Level\nEditor"
	else:
		get_node("Vinyl/1/Level1").text = "Level\nSelect"
	self.updateScoreData.connect(_onUpdateScoreData)
	$Leaderboard.position.x += slide_offset
	$Leaderboard.visible = false
	update_selection()

func _input(event: InputEvent) -> void:
	if !visible or focused:
		return
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("ui_left"):
		leaderboard_slide_in()
	elif event.is_action_pressed("ui_right"):
		leaderboard_slide_in()
	elif Input.is_action_just_pressed("ui_up"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_option = (current_option - 1 + options_count) % options_count
		update_selection()
	elif  Input.is_action_just_pressed("ui_down"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_option = (current_option + 1) % options_count
		update_selection()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		select_current_option()
	

func update_selection() -> void:
	Globals.emit_signal("playMove")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(vinyl, "rotation_degrees", 
		vinyl_rotations[current_option], rotation_tween_duration)

func select_current_option() -> void:
	Globals.emit_signal("playSelect")
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
	# Update scoreboard
	$perfectLabel.text = str(Globals.numPerfects)
	$goodLabel.text = str(Globals.numGoods)
	$barelyLabel.text = str(Globals.numBarelys)
	$missedLabel.text = str(Globals.numMisses)
	$coinsLabel.text = str(Globals.coinsCollected)
	$accuracyLabel.text = "%2.2f" % Globals.percentageHit + "%"
	$comboLabel.text = "x" + str(Globals.maxCombo)

	$Leaderboard/userScore.text = "%05d" % Globals.endScore
	playerEntry = Leaderboard.add_score(Globals.curFile, playerName, Globals.endScore)
	updateLeaderboard()
	
	# Create score animation tween
	var tween = create_tween()
	var start_score = 0
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(func(current_score: int):
		$scoreLabel.text = "%05d" % current_score,
		start_score, Globals.endScore, 3.0)

func updateLeaderboard() -> void:
	# Update leaderboard UI entries
	var scores = Leaderboard.get_level_scores(Globals.curFile)
	for i in range(scores.size()):
		var entry_node = $Leaderboard.get_node(str(i + 1))
		entry_node.text = "%05d" % scores[i].score
		entry_node.get_node("Name").text = scores[i].name

func playMusic() -> void:
	if !jingle_played:
		jingle.play(0.0)
		jingle_played = true

func slide_in() -> void:
	# Set initial position off-screen
	vinyl.position.x += slide_offset
	album.position.x += slide_offset
	albumBack.position.x += slide_offset
	
	# Create tween for slide-in animation
	var tween = create_tween()

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

func disableLeaderboard() -> void:
	$Leaderboard.visible = false

func leaderboard_slide_in() -> void:
	if $Leaderboard.visible:
		leaderboard_slide_out()
		return
	$Leaderboard.visible = true
	
	var tween = create_tween()

	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property($Leaderboard, "position:x",
		0, slide_in_duration)

func leaderboard_slide_out() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Leaderboard, "position:x",
		$Leaderboard.position.x + (slide_offset), slide_in_duration)
	tween.tween_callback(disableLeaderboard)


func _on_text_edit_text_changed() -> void:
	playerName = $Leaderboard/TextEdit.text
	if playerEntry != null:
		playerEntry.name = playerName
		updateLeaderboard()


func _on_text_edit_focus_entered() -> void:
	focused = true

func _on_text_edit_focus_exited() -> void:
	focused = false


func _on_save_button_button_down() -> void:
	$Leaderboard/TextEdit.release_focus()
	$Leaderboard/SaveButton.release_focus()
	focused = false
