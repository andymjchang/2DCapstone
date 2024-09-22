extends ProgressBar

var audioPlayer : AudioStreamPlayer2D
signal audioPlayed(value)
var isPlaying = false
var isDragging = false
var timeLeft
var timeInto


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audioPlayer = self.get_parent().get_parent().get_parent().get_node("objectList").get_node("audio")
	self.min_value = 0
	self.max_value = audioPlayer.stream.get_length()
	set_process(true)
	timeLeft = self.get_parent().get_node("timeLeft")
	timeInto = self.get_parent().get_node("timeInto")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isDragging:
		print("in isdragging")
		#stop the audio TODO
		var clickPos = get_local_mouse_position()
	
		var barWidth = self.get_node("Area2D/CollisionShape2D").shape as RectangleShape2D
		var width = barWidth.extents.x*2
		var percentage = abs(clickPos.x/width)
		var clickVal = percentage * self.max_value
		audioPlayer.seek(clickVal)
			
	self.value = audioPlayer.get_playback_position()
	timeLeft.set_text(format_time(audioPlayer.stream.get_length() - self.value))
	timeInto.set_text(format_time(self.value))


#this is a little funky 
func format_time(seconds: float) -> String:
	var why = seconds
	var minutesStr = int(seconds) / 60
	var secondsStr = int(seconds) % 60
	return str(minutesStr) + ":" + str(secondsStr)
	

	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		print("mouse released")
		isDragging = false
