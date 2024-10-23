extends Label

var lerping = false
var targetScore = 0
var currentScore = 0
var lerpDuration = 1.0  # Default duration in seconds, can be customized
var lerpProgress = 0.0

# New variables for pulsing
@export var timingScale = 1
@export var increasedScale = Vector2(1.0, 1.5)
@onready var originalScale = scale
var pulseLerpFactor = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if lerping:
		lerpProgress += delta / lerpDuration
		if lerpProgress >= 0.5: # avoids slow last number tick
			currentScore = targetScore
			lerping = false
		else:
			# Use a smoothstep function for easing
			var t = smoothstep(0, 1, lerpProgress)
			currentScore = lerp(currentScore, targetScore, t)
		
		# Update the label text with 5-digit formatting
		text = format_score(int(currentScore))
	
	processBeat(delta)

func lerpText(score: int, duration: float = 1.0):
	targetScore = float(score)
	currentScore = float(text) if text.is_valid_int() else 0
	lerpDuration = duration
	lerpProgress = 0.0
	lerping = true
	startPulse()
	

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func format_score(score: int) -> String:
	return "%05d" % score

func processBeat(delta: float) -> void:
	scale = lerp(scale, originalScale, pulseLerpFactor)
	pulseLerpFactor = min(pulseLerpFactor + delta * 2, 1)

func startPulse():
	scale = increasedScale
	pulseLerpFactor = 0.0
