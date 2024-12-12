extends CanvasLayer

enum MenuOptions {
	START,
	LEVELS,
	EDITOR,
	OPTIONS
}

var current_option: int = MenuOptions.START
@onready var music = $music
@onready var pointer = $Pointer

func _ready():
	get_tree().paused = false
	Globals.relocateToCheckpoint = false
	Globals.inEditor = false
	Globals.checkpoint = null
	music.play()
	music.stream.loop = true
	await get_tree().create_timer(0.0).timeout
	update_pointer_position()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		current_option = wrapi(current_option - 1, 0, MenuOptions.size())
		update_pointer_position()
	elif  Input.is_action_just_pressed("ui_down"):
		current_option = wrapi(current_option + 1, 0, MenuOptions.size())
		update_pointer_position()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		handle_selection()

func _input(event: InputEvent) -> void:
	if !visible:
		return
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_up"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_option = wrapi(current_option, 0, MenuOptions.size())
		update_pointer_position()
	elif  Input.is_action_just_pressed("ui_down"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_option = wrapi(current_option, 0, MenuOptions.size())
		update_pointer_position()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		handle_selection()

func controllerNavigate(val):
	pass
	#if val:
		#$storyButton.grab_focus()
		
func update_pointer_position():
	Globals.emit_signal("playMove")
	match current_option:
		MenuOptions.START:
			pointer.position.y = $storyButton.position.y + ($storyButton.size.y / 2)
			#Input.warp_mouse($storyButton.global_position + Vector2($storyButton.size.x/2, $storyButton.size.y/2))
		MenuOptions.LEVELS:
			pointer.position.y = $levelSelect.position.y + ($levelSelect.size.y / 2)
			#Input.warp_mouse($levelSelect.global_position + Vector2($levelSelect.size.x/2, $levelSelect.size.y/2))
		MenuOptions.EDITOR:
			pointer.position.y = $editorButton.position.y + ($editorButton.size.y / 2)
			#Input.warp_mouse($editorButton.global_position + Vector2($editorButton.size.x/2, $editorButton.size.y/2))
		MenuOptions.OPTIONS:
			pointer.position.y = $optionsButton.position.y + ($optionsButton.size.y / 2)
			#Input.warp_mouse($optionsButton.global_position + Vector2($optionsButton.size.x/2, $optionsButton.size.y/2))

func handle_selection():
	Globals.emit_signal("playSelect")
	var focused = get_viewport().gui_get_focus_owner()
	match current_option:
		MenuOptions.START:
			_onStoryButtonPressed()
		MenuOptions.LEVELS:
			_onLevelSelectPressed()
		MenuOptions.EDITOR:
			_onEditorButtonPressed()
		MenuOptions.OPTIONS:
			_onOptionsButtonPressed()

func _onStoryButtonPressed():
	Globals.FadeTransition("res://worlds/levelTemplate.tscn")

func _onEditorButtonPressed():
	# get_tree().change_scene_to_file("res://levelEditor/levelEditor.tscn")
	Globals.FadeTransition("res://levelEditor/levelEditor.tscn")
	
func _onLevelSelectPressed() -> void:
	Globals.FadeTransition("res://ui/levelSelect.tscn")
	


func _onOptionsButtonPressed() -> void:
	Globals.FadeTransition("res://ui/options.tscn")
