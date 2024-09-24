extends ProgressBar

var audioPlayer : AudioStreamPlayer2D
signal audioPlayed(value)
var isPlaying = false
var isDragging = false
var timeLeft
var timeInto


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("audio: ", self.get_parent().get_parent())
	audioPlayer = self.get_parent().get_parent().get_node("Camera2D/Music")
	self.min_value = 0
	self.max_value = audioPlayer.stream.get_length()
	set_process(true)
	timeLeft = self.get_parent().get_node("timeLeft")
	timeInto = self.get_parent().get_node("timeInto")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:			
	self.value = audioPlayer.get_playback_position()
	#add these in TODO
	#timeLeft.set_text(format_time(audioPlayer.stream.get_length() - self.value))
	#timeInto.set_text(format_time(self.value))


#this is a little funky 
func format_time(seconds: float) -> String:
	var why = seconds
	var minutesStr = int(seconds) / 60
	var secondsStr = int(seconds) % 60
	return str(minutesStr) + ":" + str(secondsStr)
	
