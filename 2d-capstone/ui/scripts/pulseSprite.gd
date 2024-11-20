extends Sprite2D

# variables for controlling pulse
@export var timingScale = 1
@export var increasedScale = Vector2(1.2, 1.2)
@onready var originalScale = scale
var beatInterval = 0.0
var beatTimer = 0.0
var lerpFactor = 0.0
var isPulseActive = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func setBPM():
	beatInterval = timingScale * 60.0 / Globals.bpm
	isPulseActive = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isPulseActive:
		processBeat(delta)

func processBeat(delta: float) -> void:
	beatTimer += delta * Globals.scrollSpeed
	if beatTimer >= beatInterval:
		beatTimer -= beatInterval
		startPulse()
		
	scale = lerp(scale, originalScale, lerpFactor)
	lerpFactor = min(lerpFactor + delta * 2, 1)

func startPulse():
	scale = increasedScale
	lerpFactor = 0.0
