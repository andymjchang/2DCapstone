extends Node2D

signal speedChange(newSpeed)


@onready var animation = $tutorialSlides
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.speedChange.connect(_onSpeedChange)
	animation.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get the time and do frames based on that 
	pass
	
func _onSpeedChange(newSpeed) -> void:
	print("made it to speed chaneg pop up u")
	animation.speed_scale = newSpeed


func _onTutorialSlidesSnimationFinished() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
	