extends Node

const physicsFrameRate : float = 60
const beatSize : float = 150

var time : float = 0;
var levelEditorTime = 0.0
var inLevel = false
var vertical = false
var resetCamera = false
var paused = false
var stepSize = 0
var checkpoint = null
var relocateToCheckpoint = false
var pixelsPerFrame = 300
var scrollSpeed = 1
var curFile = ""
var bpm : float = 156

var areaClicked = false
var startP1Coords
var startP2Coords
var customStart = false

#player level details 
var coinsCollected = 0.0
var numBarelys = 0.0
var numPerfects = 0.0
var numGoods = 0.0
var percetageHit = 0.0
var endScore = 0.0
var gameOver = false 

#volume 
var playerSoundsVolume =1.0
var musicSoundsVolume = 1.0
var levelMusicSoundsVolume = 1.0

var allVolumes = [playerSoundsVolume, musicSoundsVolume, levelMusicSoundsVolume]

enum powerType {
	INVULN,
	HEAL,
	SPEEDUP,
	SLOWDOWN
}


# File Names
var currentEditorFileName
var currentSongFileName

# Nodes
var previewNode
@onready var editorNode = preload("res://levelEditor/levelEditor.tscn")
@onready var screenFlashNode = preload("res://screenEffects/screenFlashEffect.tscn")
@onready var vignette = $Vignette/ColorRect
@onready var glitch = $Glitch/TransitionRect

func _ready():
	randomize()

#func _process(delta: float) -> void:
	#time += delta;

func enablePreviewUI():
	$PreviewCanvasLayer.visible = true
func disablePreviewUI():
	$PreviewCanvasLayer.visible = false
func setBPM(p_bpm : float):
	self.bpm = p_bpm
	pixelsPerFrame = bpm * beatSize / physicsFrameRate

func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_packed(editorNode)
	disablePreviewUI()
	inLevel = false
	
func screenFlashEffect():
	var screenFlashInstance = screenFlashNode.instantiate()
	screenFlashInstance.screenFlash(0.25, 0.3)
	add_child(screenFlashInstance)
	
func get_random_sign():
	return -1 if randi() % 2 == 0 else 1
	
func FadeIn():
	var tween = create_tween()
	tween.tween_property(vignette.material, "shader_parameter/inner_radius", -1.2, 0.5)
	
func FadeOut(sceneFileName : String):
	get_tree().change_scene_to_file(sceneFileName)
	var tween = create_tween()
	tween.tween_property(vignette.material, "shader_parameter/inner_radius", 0.5, 0.5)
	tween.tween_property(glitch.material, "shader_parameter/shake_power", 0.0, 0.25)
	tween.tween_property(glitch.material, "shader_parameter/fade", 0.001, 0.25)

func FadeTransition(sceneFileName : String):
	# Chain the transitions together
	var tween = create_tween()
	tween.tween_property(vignette.material, "shader_parameter/inner_radius", -1.2, 0.5)
	tween.tween_property(glitch.material, "shader_parameter/shake_power", 0.3, 0.25)
	tween.tween_property(glitch.material, "shader_parameter/fade", 0.01, 0.25)
	tween.tween_interval(0.1)  # Optional small pause between transitions
	tween.tween_callback(func(): FadeOut(sceneFileName))

func restartLevelData() -> void:
	numBarelys = 0.0
	numGoods = 0.0
	numPerfects = 0.0
	endScore = 0.0
	coinsCollected = 0.0
	percetageHit = 0.0
