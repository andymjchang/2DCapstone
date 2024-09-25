extends CanvasLayer
@onready var curP1Heart = $player1/UiHeart3
@onready var curP2Heart = $player2/UiHeart3
var curP1HeartIndex = 2
var curP2HeartIndex = 2
signal decreaseHealth(who)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.decreaseHealth.connect(_onDamageTaken)
	#set the individual ui hearts for each player
	for heart in self.get_node("player1").get_children():
		heart.player = "player1"
	for heart in self.get_node("player2").get_children():
		heart.player = "player2"
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _onDamageTaken(who) -> void:
	#do damage on current heart
	print("damage signal connected")
	if who == "Player1":
		curP1Heart.takeDamage()
		if curP1Heart.healthStatus == "zero" and curP1HeartIndex != 0:
			#player has lost a heart
			curP1HeartIndex -= 1
			curP1Heart = self.get_child(curP1HeartIndex)
	if who == "Player2":
		curP2Heart.takeDamage()
		if curP2Heart.healthStatus == "zero" and curP2HeartIndex != 0:
			#player has lost a heart
			curP2HeartIndex -= 1
			curP2Heart = self.get_child(curP2HeartIndex)
		
	
	
