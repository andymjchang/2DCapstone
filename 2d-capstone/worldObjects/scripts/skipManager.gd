extends Node2D


@onready var skipArray
@onready var currentWorldScene
var currentIndex = 0
var startingIndex = 0
var activatedSkip
var defaultText = "Skip Number: "
@onready var textBox = $CanvasLayer/RichTextLabel

func loadArray():
	skipArray = get_tree().get_nodes_in_group("skips")
	#for skip in skipArray:
		#indicator.initialize()
	skipArray.sort_custom(sortSkips)
	currentWorldScene = get_tree().current_scene
	

func sortSkips(a, b):
	if a.global_position.x < b.global_position.x:
		return true
	return false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currentIndex = startingIndex
	var currentScene = get_tree().current_scene
	while currentIndex < skipArray.size():
		var skip = skipArray[currentIndex]
		currentIndex += 1
		if currentScene.get_node("objectList/players/Player1").global_position >= skip.global_position:
			#print("current time" + str(currentWorldScene.time))
			activatedSkip = skip
			textBox.text = defaultText + str(currentIndex)
		else:
			break
			
			
		if Input.is_action_just_pressed("tab"):
		#skip to the next thing
			skipToNext()
		
func skipToNext():
	if currentIndex + 1 >= skipArray.size():
		return
	currentIndex+=1
	textBox.text = defaultText + str(currentIndex)
	activatedSkip = skipArray[currentIndex]
	get_tree().current_scene.emit_signal("movePlayer", activatedSkip.global_position)
	
	#now we have to ove player
	
