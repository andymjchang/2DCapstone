extends CanvasLayer

enum MenuOptions {
	START,
	LEVELS,
	EDITOR,
	OPTIONS,
	QUIT
}

var current_option: int = MenuOptions.START
@onready var music = $music
@onready var pointer = $Pointer

func _ready():
	Globals.relocateToCheckpoint = false
	Globals.checkpoint = null
	music.play()
	music.stream.loop = true
	update_pointer_position()

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		current_option = wrapi(current_option - 1, 0, MenuOptions.size())
		update_pointer_position()
	elif Input.is_action_just_pressed("slide"):
		current_option = wrapi(current_option + 1, 0, MenuOptions.size())
		update_pointer_position()
	
	if Input.is_action_just_pressed("ui_accept"):
		handle_selection()

func update_pointer_position():
	match current_option:
		MenuOptions.START:
			pointer.position.y = $storyButton.position.y + ($storyButton.size.y / 2)
		MenuOptions.LEVELS:
			pointer.position.y = $levelSelect.position.y + ($levelSelect.size.y / 2)
		MenuOptions.EDITOR:
			pointer.position.y = $editorButton.position.y + ($editorButton.size.y / 2)
		MenuOptions.OPTIONS:
			pointer.position.y = $optionsButton.position.y + ($optionsButton.size.y / 2)
		MenuOptions.QUIT:
			pointer.position.y = $quitButton.position.y + ($quitButton.size.y / 2)

func handle_selection():
	match current_option:
		MenuOptions.START:
			_onStoryButtonPressed()
		MenuOptions.LEVELS:
			_onLevelSelectPressed()
		MenuOptions.EDITOR:
			_onEditorButtonPressed()
		MenuOptions.OPTIONS:
			_onOptionsButtonPressed()
		MenuOptions.QUIT:
			_onQuitButtonPressed()

func _onStoryButtonPressed():
	Globals.FadeTransition("res://worlds/levelTemplate.tscn")

func _onEditorButtonPressed():
	# get_tree().change_scene_to_file("res://levelEditor/levelEditor.tscn")
	Globals.FadeTransition("res://levelEditor/levelEditor.tscn")

func _onQuitButtonPressed():
	get_tree().quit()
	
func _onLevelSelectPressed() -> void:
	get_tree().change_scene_to_file("res://ui/levelSelect.tscn")
	


func _onOptionsButtonPressed() -> void:
	Globals.FadeTransition("res://ui/options.tscn")
