extends TextureProgressBar

var audioPlayer : AudioStreamPlayer2D
@onready var noteIcon = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("what did i change??? ", self.get_parent().get_parent().get_node("Camera2D/Music"))
	audioPlayer = self.get_parent().get_parent().get_node("Camera2D/Music")
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:			
	if audioPlayer.has_stream_playback():
		self.value = audioPlayer.get_playback_position()
	#noteIcon.positon = self.value
	#var barWidth = self.get_node("Area2D/CollisionShape2D").shape as RectangleShape2D
	#var width = barWidth.extents.x*2
	#var percentage = self.value/self.max_value
	#var clickVal = percentage * self.max_value
