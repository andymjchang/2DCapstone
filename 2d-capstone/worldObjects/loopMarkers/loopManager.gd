extends Node2D

@onready var start = $LoopMarkerStart
@onready var end = $LoopMarkerEnd
@export var label : Label

enum {START, END}

var startTime
var enemiesToRespawn = []
var powerupsToRespawn = []
var jumpsToRespawn = []
var firstPass = true

var enemiesToDespawn = []
var powerupsToDespawn = []

var loopMax = 1
var loopNum = 0

signal recordData()
signal resetData()
signal recordEnemies(enemyPos)
signal recordPowers(powerPos)

var display_text = "The Conductor rewinds the song..."
var current_display_text = ""
var char_index = 0
var char_timer = 0
var char_delay = 0.05  # Delay between each character
var fade_timer = 0
var is_animating = false
var is_fading = false

# Called when the node enters the scene tree for the first time.
func _init():
	recordData.connect(_onRecordData)
	resetData.connect(_onResetData)
	recordEnemies.connect(_onRecordEnemies)
	recordPowers.connect(_onRecordPowers)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_animating:
		char_timer += delta
		if char_timer >= char_delay:
			char_timer = 0
			if char_index < display_text.length():
				current_display_text += display_text[char_index]
				label.text = current_display_text
				char_index += 1
			else:
				is_animating = false
				is_fading = true
				fade_timer = 0
				
	if is_fading:
		fade_timer += delta
		if fade_timer >= 5.0:  # Start fading after 5 seconds
			label.modulate.a = max(0, label.modulate.a - (delta * 2))  # Fade out over 0.5 seconds
			if label.modulate.a <= 0:
				is_fading = false
				current_display_text = ""
				char_index = 0
				label.text = ""

func _onRecordData():
	#print("Hit start, recording data")
	startTime = Globals.time
	#print("Restart at this time: ", startTime)

func _onResetData(destination):
	print("Resetting my loop")
	loopNum += 1
	if loopNum <= loopMax:
		# Initialize text animation
		current_display_text = ""
		char_index = 0
		char_timer = 0
		is_animating = true
		is_fading = false
		label.modulate.a = 1.0
		
		for enemy in enemiesToDespawn:
			if enemy != null:
				enemy.queue_free()
		for power in powerupsToDespawn:
			if power != null:
				power.queue_free()
		enemiesToDespawn = []
		powerupsToDespawn = []
		startTime = abs(0.0 - destination.global_position.x) / Globals.pixelsPerFrame
		get_tree().root.get_node("level").emit_signal("resetLoop", startTime, destination, enemiesToRespawn, powerupsToRespawn)

func _onRecordEnemies(enemy):
	if firstPass and !enemy.ifDead:
		enemiesToRespawn.append(enemy.global_position)
	#print("Need to respawn: ", enemiesToRespawn)
	enemiesToDespawn.append(enemy)

func _onRecordPowers(power):
	print("Need to respawn: ", powerupsToRespawn)
	if firstPass:
		powerupsToRespawn.append(power.global_position)
	powerupsToDespawn.append(power)
