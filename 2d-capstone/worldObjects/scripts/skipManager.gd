extends Node2D


@onready var skipArray
@onready var currentWorldScene
var currentIndex = 0
var startingIndex = 0
var activatedSkip
var defaultText = "Skip Number: "
var arrayLoaded = false
@onready var textBox = $CanvasLayer/VBoxContainer/RichTextLabel

func loadArray():
	skipArray = get_tree().get_nodes_in_group("skips")
	skipArray.sort_custom(sortSkips)
	currentWorldScene = get_tree().current_scene
	currentIndex = 0
	activatedSkip = skipArray[currentIndex]
	arrayLoaded = true
	
	

func sortSkips(a, b):
	if a.global_position.x < b.global_position.x:
		return true
	return false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var currentScene = get_tree().current_scene
	while currentIndex < skipArray.size() and arrayLoaded:
		var skip = skipArray[currentIndex]
		print("grabbing skip ", currentIndex)
		if currentScene.get_node("objectList/players/Player1").global_position >= skip.global_position:
			#print("current time" + str(currentWorldScene.time))
			activatedSkip = skip
			textBox.text = defaultText 	+ str(currentIndex)
			currentIndex += 1
			print("just passed a skip, new skip index: ", currentIndex)
		else:
			break
	if Input.is_action_just_pressed("tab"):
		#skip to the next thing
		skipToNext()
		
	

func skipToNext():
	currentIndex+=1
	print("skipping to a skip that is the start")
	textBox.text = defaultText + str(currentIndex)
	activatedSkip = skipArray[currentIndex]
	print("index Im skipping too: ", currentIndex)	
	get_tree().current_scene.emit_signal("movePlayer", activatedSkip.global_position)
