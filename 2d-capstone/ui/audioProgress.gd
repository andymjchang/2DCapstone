extends ProgressBar

var audioPlayer : AudioStreamPlayer2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audioPlayer = self.get_parent().get_parent().get_node("Camera2D/Music")
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:			
	self.value = audioPlayer.get_playback_position()
	
