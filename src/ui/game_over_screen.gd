extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_hit.connect(_on_player_hit)
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event.is_action_pressed("ok"):
		if event.is_pressed():
			SignalBus.game_start.emit()
			visible = false


func _on_player_hit() -> void:
	visible = true
