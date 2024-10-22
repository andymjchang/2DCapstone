extends Node

const physicsFrameRate : float = 60
const beatSize : float = 150

var time : float = 0;
var inLevel = false
var paused = false
var stepSize = 0
var pixelsPerFrame : float = 300
var scrollSpeed = 1
var curFile = ""
var bpm : float = 156

var areaClicked = false
var startP1Coords
var startP2Coords
var customStart = false


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
@onready var vignette = $PreviewCanvasLayer

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
