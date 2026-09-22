extends Area2D
class_name Pipe

@onready var green: Sprite2D = %Green
@onready var red: Sprite2D = %Red

@export var pipe_orientation = PipeOrientation.TOP
@export var pipe_color = PipeColor.GREEN

enum PipeOrientation {
	TOP,
	BOTTOM,
}

enum PipeColor {
	GREEN,
	RED
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if pipe_orientation == PipeOrientation.BOTTOM:
		green.flip_v = true
		red.flip_v = true

	if pipe_color == PipeColor.GREEN:
		green.visible = true
		red.visible = false
	else:
		green.visible = false
		red.visible = true


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
		
	SignalBus.player_hit.emit()
