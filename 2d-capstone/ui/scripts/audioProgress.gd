extends TextureProgressBar

var audioPlayer : AudioStreamPlayer2D
@onready var noteIcon = $Sprite2D

var startX


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audioPlayer = self.get_parent().get_parent().get_node("Camera2D/Music")
	startX = noteIcon.global_position.x
	set_process(true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:			
	if audioPlayer.has_stream_playback():
		self.value = audioPlayer.get_playback_position()
		#note icon is always a little ahead
		#var barWidth = self.get_node("Area2D/CollisionShape2D").shape as RectangleShape2D
		#var width = self.get_rect().size.x
		#var percentage = self.value/self.max_value
		#var barPlace = width*percentage
		#print("self?, ", percentage)
		#
		#if percentage > 0.10:
			#noteIcon.global_position.x = startX + barPlace
		
		
	#var clickVal = percentage * self.max_elfsvalue
