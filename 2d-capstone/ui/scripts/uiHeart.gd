extends Node2D
#signal decreaseHealth()

var healthStatus= "full"
var player : String 
@onready var fullHealth = $fullP1Health
@onready var zeroHealth = $zeroP1Health
var changed = true

# variables for controlling pulse
@onready var originalScale = self.transform.get_scale()
var increasedScale = Vector2(1.2, 1.2)
var beatInterval = 0.0
var beatTimer = 0.0
var lerpFactor = 0.0

# Called when the node enters the scene tree for the first time.
#TODO add this for both players
func _ready() -> void:
	#connect signal for when player takes damage
	#self.decreaseHealth.connect(_onDamageTaken)
	if player == "player1":
		self.get_node("fullP1Health").visible = true
		self.get_node("zeroP1Health").visible = false
		fullHealth = $fullP1Health
	if player == "player2":
		self.get_node("fullP2Health").visible = true
		self.get_node("zeroP2Health").visible = false
		zeroHealth = $zeroP2Health
		
	# set beat interval
	beatInterval = 60.0 / Globals.bpm

func processBeat(delta: float) -> void:
	beatTimer += delta
	
	if beatTimer >= beatInterval:
		beatTimer -= beatInterval
		scale = increasedScale
		lerpFactor = 0.0
	scale = lerp(scale, originalScale, lerpFactor)
	lerpFactor = min(lerpFactor + delta * 2, 1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == "player2" and changed:
		self.get_node("fullP2Health").visible = true
		self.get_node("zeroP2Health").visible = false
		self.get_node("fullP1Health").visible = false
		self.get_node("zeroP1Health").visible = false
		changed = false
		zeroHealth = $zeroP2Health
		fullHealth = $fullP2Health
	
	processBeat(delta)
		
#is this redundant?	
func takeDamage() -> void:
	match healthStatus:
		"full":
			#decrease to half
			self.fullHealth.visible = false
			self.zeroHealth.visible = true
			healthStatus = "zero"
		"zero":
			#should not be getting here
			print("should not be checking heart still")
