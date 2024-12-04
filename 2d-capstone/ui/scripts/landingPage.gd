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
	get_tree().paused = false
	Globals.relocateToCheckpoint = false
	Globals.checkpoint = null
	music.play()
	music.stream.loop = true
	await get_tree().create_timer(0.0).timeout
	update_pointer_position()

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		current_option = wrapi(current_option - 1, 0, MenuOptions.size())
		update_pointer_position()
	elif Input.is_action_just_pressed("slide"):
		current_option = wrapi(current_option + 1, 0, MenuOptions.size())
		update_pointer_position()
	elif Input.is_action_just_pressed("punch") and Globals.usingController:
		print("gettig to pucnh detetion")
		handle_selection()
	elif Input.is_action_pressed("ui_accept"):
		handle_selection()

func controllerNavigate(val):
	if val:
		$storyButton.grab_focus()
		
func update_pointer_position():
	match current_option:
		MenuOptions.START:
			pointer.position.y = $storyButton.position.y + ($storyButton.size.y / 2)
			Input.warp_mouse($storyButton.global_position + Vector2($storyButton.size.x/2, $storyButton.size.y/2))
		MenuOptions.LEVELS:
			pointer.position.y = $levelSelect.position.y + ($levelSelect.size.y / 2)
			Input.warp_mouse($levelSelect.global_position + Vector2($levelSelect.size.x/2, $levelSelect.size.y/2))
		MenuOptions.EDITOR:
			pointer.position.y = $editorButton.position.y + ($editorButton.size.y / 2)
			Input.warp_mouse($editorButton.global_position + Vector2($editorButton.size.x/2, $editorButton.size.y/2))
		MenuOptions.OPTIONS:
			pointer.position.y = $optionsButton.position.y + ($optionsButton.size.y / 2)
			Input.warp_mouse($optionsButton.global_position + Vector2($optionsButton.size.x/2, $optionsButton.size.y/2))
		MenuOptions.QUIT:
			pointer.position.y = $quitButton.position.y + ($quitButton.size.y / 2)
			Input.warp_mouse($quitButton.global_position + Vector2($quitButton.size.x/2, $quitButton.size.y/2))

func handle_selection():
	var focused = get_viewport().gui_get_focus_owner()
	print("focused: ", focused)
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
	Globals.FadeTransition("res://ui/levelSelect.tscn")
	


func _onOptionsButtonPressed() -> void:
	Globals.FadeTransition("res://ui/options.tscn")
