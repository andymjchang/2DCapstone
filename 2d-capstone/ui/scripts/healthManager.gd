extends CanvasLayer
@onready var curP1Heart = $player1/UiHeart3
@onready var curP2Heart = $player2/UiHeart3
var curP1HeartIndex = 2
var curP2HeartIndex = 2
signal decreaseHealth(who)
signal increaseHealth(who)
signal reviveUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.decreaseHealth.connect(_onDamageTaken)
	self.increaseHealth.connect(_onHealingTaken)
	self.reviveUI.connect(_onUIRevive)
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
	print("ui health damage!")
	if who == "Player2":
		if curP1Heart:
			curP1Heart.takeDamage()
			if curP1Heart.healthStatus == "zero" and curP1HeartIndex != 0:
				#player has lost a heart
				curP1HeartIndex -= 1
				curP1Heart = self.get_node("player1").get_child(curP1HeartIndex)
	if who == "Player1":
		#need to check to make sure not dead
		if curP2Heart:
			curP2Heart.takeDamage()
			if curP2Heart.healthStatus == "zero" and curP2HeartIndex != 0:
				#player has lost a heart
				curP2HeartIndex -= 1
				curP2Heart = self.get_node("player2").get_child(curP2HeartIndex)

	
func _onHealingTaken(who) -> void:
	#do damage on current heart
	print("ui heal!")
	if who == "Player2":
		if curP1Heart:
			curP1Heart.takeDamage()
			if curP1Heart.healthStatus == "zero" and curP1HeartIndex != 0:
				#player has lost a heart
				curP1HeartIndex += 1
				curP1Heart = self.get_node("player1").get_child(curP1HeartIndex)
	if who == "Player1":
		if curP2Heart:
			if curP2HeartIndex + 1 < 3:
				curP2HeartIndex += 1
			else:
				curP2HeartIndex = 3
			curP2Heart = self.get_node("player2").get_child(curP2HeartIndex)
				
func _onUIRevive(who):
	print("made it to ui revive")
	if who == "Player2":
		curP1Heart =  $player1/UiHeart3
		curP1HeartIndex = 2
		for heart in get_node("player1").get_children():
			heart.healthStatus = "full"
			heart.fullHealth.visible = true
			heart.zeroHealth.visible = false
	if who == "Player1":
		curP2Heart =  $player2/UiHeart3
		curP2HeartIndex = 2
		for heart in get_node("player2").get_children():
			heart.healthStatus = "full"
			heart.fullHealth.visible = true
			heart.zeroHealth.visible = false
		
		
	
	
