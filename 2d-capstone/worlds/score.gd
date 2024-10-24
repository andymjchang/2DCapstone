extends Label

var lerping = false
var targetScore = 0
var currentScore = 0
var lerpDuration = 1.0  # Default duration in seconds, can be customized
var lerpProgress = 0.0

# New variables for pulsing
@export var increasedScale = Vector2(1.2, 1.2)
@onready var originalScale = scale
var lerpFactor = 0.0

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

	# Add pulsing effect
	scale = lerp(scale, originalScale, lerpFactor)
	lerpFactor = min(lerpFactor + delta * 2, 1)

func lerpText(score: int, duration: float = 1.0):
	targetScore = float(score)
	currentScore = float(text) if text.is_valid_int() else 0
	Globals.endScore = currentScore
	lerpDuration = duration
	lerpProgress = 0.0
	lerping = true
	
	# Trigger pulse effect
	startPulse()

# New function for pulsing
func startPulse():
	scale = increasedScale
	lerpFactor = 0.0

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func format_score(score: int) -> String:
	return "%05d" % score
