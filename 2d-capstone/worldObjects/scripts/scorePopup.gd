extends Node2D

const FADE_TIME = 0.5

@export var greenTiming : Texture
@export var yellowTiming : Texture
@export var redTiming : Texture
@export var pop_scale := 1.5
@export var pop_duration := 0.3
@export var letters_per_group := 2
@export var delay_between_groups := 0.1

@onready var label
@onready var clefSprite
var fadeMode = false
var fadeTimer = FADE_TIME
var hasFadeStarted = false
var trackedNode
var min_rotation
var max_rotation
var clefDefaultPosition
var letter_nodes: Array[Label] = []
var tween: Tween

func _ready():
	label = $CanvasLayer/Label
	clefSprite = $CanvasLayer/clefSprite
	label.text = ""
	clefDefaultPosition = clefSprite.position
	
	clefSprite.modulate.a = 0.0
	
	var min_rotation_degrees = -1.5
	var max_rotation_degrees = 1.5
	# Convert degrees to radians for rotation
	min_rotation = min_rotation_degrees * (PI / 180)
	max_rotation = max_rotation_degrees * (PI / 180)

func initPosition(node):
	trackedNode = node
	position = node.get_global_position() - get_parent().position
	position.x += 200

func initText(text, _player_position):
	$sfxPlayer.play()
	var labelText = ""
	if text > 85:
		labelText = "PERFECT!"
		clefSprite.texture = greenTiming
		Globals.numPerfects+=1
	elif text > 75:
		labelText = "GREAT!"
		clefSprite.texture = greenTiming
	elif text > 65:
		labelText = "GOOD!"
		clefSprite.texture = yellowTiming
		Globals.numGoods += 1
	else: 
		labelText = "BARELY!"
		clefSprite.texture = redTiming
		Globals.numBarelys += 1
	
	# Clear previous letter nodes
	for letter in letter_nodes:
		letter.queue_free()
	letter_nodes.clear()
	
	# Create individual labels for each letter
	var offset := 0.0
	for i in labelText.length():
		var letter_label := Label.new()
		letter_label.text = labelText[i]
		letter_label.position.x = offset
		letter_label.scale = Vector2.ZERO  # Start invisible
		letter_label.theme = label.theme  # Copy the theme from the main label
		letter_label.add_theme_font_override("font", label.get_theme_font("font"))  # Copy the font
		letter_label.add_theme_font_size_override("font_size", label.get_theme_font_size("font_size"))  # Copy the font size
		letter_label.add_theme_constant_override("outline_size", label.get_theme_constant("outline_size"))  # Copy the outline size
		label.add_child(letter_label)
		letter_nodes.append(letter_label)
		offset += letter_label.size.x
	
	label.text = ""  # Clear the main label
	fadeMode = true
	fadeTimer = FADE_TIME
	label.modulate.a = 1.0
	
	clefSprite.modulate.a = 1.0
	clefSprite.position = clefDefaultPosition
	clefSprite.scale = Vector2(0.7, 0.7)  # Start with larger scale
	
	rotation = randf_range(min_rotation, max_rotation)
	
	# Start the pop animation
	animate_text()
	animate_clef()

func animate_text():
	if tween:
		tween.kill()
	tween = create_tween()
	
	for i in range(0, letter_nodes.size(), letters_per_group):
		var end_idx = mini(i + letters_per_group, letter_nodes.size())
		
		for j in range(i, end_idx):
			var letter = letter_nodes[j]
			
			tween.parallel().tween_property(
				letter,
				"scale",
				Vector2.ONE * pop_scale,
				pop_duration * 0.5
			).set_delay(i * delay_between_groups)
			
			tween.parallel().tween_property(
				letter,
				"scale",
				Vector2.ONE,
				pop_duration * 0.5
			).set_delay(i * delay_between_groups + pop_duration * 0.5)

func animate_clef():
	var clef_tween = create_tween()
	clef_tween.tween_property(
		clefSprite,
		"scale",
		Vector2(0.5, 0.5),
		pop_duration
	)

func _process(delta: float) -> void:
	# track player position
	position.y = trackedNode.position.y - get_parent().position.y
	
	# fade
	clefSprite.position.y -= 0.15
	if fadeMode:
		if fadeTimer > 0:
			fadeTimer -= delta
		elif not hasFadeStarted:
			hasFadeStarted = true
			label.modulate.a = 1.0  # Reset alpha when fade starts
			clefSprite.modulate.a = 1.0
		else:
			label.modulate.a -= 0.02
			clefSprite.modulate.a -= 0.02
	if label.modulate.a <= 0:
		fadeMode = false
		fadeTimer = FADE_TIME # Reset timer for next use
		hasFadeStarted = false
