extends CanvasLayer
@onready var curHeart = $UiHeart3
var curHeartIndex = 2
signal decreaseHealth

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.decreaseHealth.connect(_onDamageTaken)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _onDamageTaken() -> void:
	#do damage on current heart
	print("damage signal connected")
	curHeart.takeDamage()
	if curHeart.healthStatus == "zero" and curHeartIndex != 0:
		#player has lost a heart
		curHeartIndex -= 1
		curHeart = self.get_child(curHeartIndex)
	
