extends Node

var time = 0;
var inLevel = false
var stepSize = 0

var previewNode
var currentEditorFileName
@onready var editorNode = preload("res://levelEditor/levelEditor.tscn")

func _process(delta: float) -> void:
	time += delta;

func enablePreviewUI():
	$PreviewCanvasLayer.visible = true
func disablePreviewUI():
	$PreviewCanvasLayer.visible = false


func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_packed(editorNode)
	disablePreviewUI()
