extends Node

const physicsFrameRate = 60
const beatSize = 150

var time = 0;
var inLevel = false
var stepSize = 0
var pixelsPerFrame = 300
var curFile = ""

var areaClicked = false
var startP1Coords
var startP2Coords
var customStart = false


# File Names
var currentEditorFileName
var currentSongFileName

# Nodes
var previewNode
@onready var editorNode = preload("res://levelEditor/levelEditor.tscn")
@onready var screenFlashNode = preload("res://screenEffects/screenFlashEffect.tscn")

func _process(delta: float) -> void:
	time += delta;

func enablePreviewUI():
	$PreviewCanvasLayer.visible = true
func disablePreviewUI():
	$PreviewCanvasLayer.visible = false
func setBPM(bpm):
	pixelsPerFrame = bpm * beatSize / physicsFrameRate

func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_packed(editorNode)
	disablePreviewUI()
	inLevel = false
	
func screenFlashEffect():
	var screenFlashInstance = screenFlashNode.instantiate()
	screenFlashInstance.screenFlash(0.25, 0.3)
	add_child(screenFlashInstance)
