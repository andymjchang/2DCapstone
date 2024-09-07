extends Node2D

signal resetPosition(who)

var player1 
var player2
var killWall

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resetPosition.connect(_onResetPosition)
	player1 = get_node("Player1")
	player2 = get_node("Player2")
	killWall = get_node("KillWall")
	await get_tree().create_timer(3.0).timeout
	Globals.inLevel = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(killWall.position.x)
	pass

# Hard coded right now
func _onResetPosition(who):
	print("resetting player pos")
	if who == "Player1":
		player1.position.x = killWall.position.x + 45
		player1.position.y -= 100
		pass
	elif who == "Player2":
		player2.position.x = killWall.position.x + 45
		player2.position.y -= 100
		pass
