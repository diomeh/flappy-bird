extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event.is_action_pressed("ok"):
		if event.is_pressed():
			SignalBus.game_start.emit()
			visible = false
