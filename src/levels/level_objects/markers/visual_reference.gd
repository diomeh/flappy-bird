@tool
extends Node2D


func _ready() -> void:
	# These reference visuals should only appear in the editor
	if not Engine.is_editor_hint():
		queue_free()
