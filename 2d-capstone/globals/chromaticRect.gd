extends ColorRect

@export var animation_duration: float = 0.5
@export var max_fade: float = 0.001

var time: float = 0
var increasing: bool = true

func _process(delta: float) -> void:
	time += delta
	
	# Calculate the progress of the current animation cycle
	var progress = time / animation_duration
	
	if increasing:
		# Ease in
		var fade = ease_in_out(progress) * max_fade
		material.set_shader_parameter("fade", fade)
		
		if progress >= 1.0:
			increasing = false
			time = 0
	else:
		# Ease out
		var fade = ease_in_out(1.0 - progress) * max_fade
		material.set_shader_parameter("fade", fade)
		
		if progress >= 1.0:
			increasing = true
			time = 0

# Custom easing function combining ease in and out for smoother transition
func ease_in_out(t: float) -> float:
	if t < 0.5:
		return 2.0 * t * t
	else:
		t = 2.0 * t - 1.0
		return -0.5 * (t * (t - 2.0) - 1.0)
