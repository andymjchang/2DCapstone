extends Node2D


@onready var skipArray
@onready var currentWorldScene
var currentIndex = 0
var startingIndex = 0
var activatedSkip
var defaultText = "Skip Number: "
var arrayLoaded = false
var pastFirst = false
@onready var textBox = $CanvasLayer/VBoxContainer/RichTextLabel

func loadArray():
	skipArray = get_tree().current_scene.get_node("objectList/skips").get_children()
	print("All the skips in my array before filtering: ", skipArray)
	for node in skipArray:
		if node.name == "CanvasLayer":
			skipArray.erase(node)

	print("all the skips in my array: ", skipArray)
	skipArray.erase("CanvasLayer")
	skipArray.sort_custom(sortSkips)
	print("all the skips in my array: ", skipArray)
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
	#while currentIndex < skipArray.size() and arrayLoaded:
	if skipArray.size() > 0:
		var skip = skipArray[currentIndex]
		if currentScene.get_node("objectList/players/Player1").global_position.x >= skip.global_position.x:
			currentIndex = skipArray.find(activatedSkip)
			#currentIndex = currentIndex + 1
			skip = skipArray[currentIndex]
			activatedSkip = skip
			textBox.text = defaultText 	+ str(currentIndex)
			pastFirst = true
			#print("current time" + str(currentWorldScene.time))
			
			
			#currentIndex += 1
			print("just passed a skip, new skip index: ", currentIndex)

	if Input.is_action_just_pressed("tab"):
		#skip to the next thing
		skipToNext()
		
	

func skipToNext():
	if currentIndex == 0 and !pastFirst:
		activatedSkip = skipArray[0]
	elif currentIndex < skipArray.size() - 1 :
		currentIndex = skipArray.find(activatedSkip)
		currentIndex = currentIndex + 1
		print("skipping to a skip that is the start")
		textBox.text = defaultText + str(currentIndex)
		activatedSkip = skipArray[currentIndex]
		print("index Im skipping too: ", currentIndex)	
		get_tree().current_scene.emit_signal("movePlayer", activatedSkip.global_position)
