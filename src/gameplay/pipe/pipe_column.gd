extends Node2D
class_name PipeColumn

const SPEED = 100

const BIRD_SIZE = 24.0 # Taken from bird sprite
const GAP_MIN = BIRD_SIZE * 5
const GAP_MAX = BIRD_SIZE * 6

const PIPE_HALF_HEIGHT = 160.0

const PIPE_PATH_GREEN = "res://assets/art/world/pipe/green.png"
const PIPE_PATH_RED = "res://assets/art/world/pipe/red.png"

enum PipeColor {
	GREEN,
	RED,
}

@export var pipe_color = PipeColor.GREEN

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var top_pipe: Sprite2D = %TopPipe
@onready var bottom_pipe: Sprite2D = %BottomPipe

@onready var top: Node2D = %Top
@onready var top_area: Area2D = %TopArea

@onready var gap_area: Area2D = %GapArea
@onready var gap_collision: CollisionShape2D = %GapCollision

@onready var bottom: Node2D = %Bottom
@onready var bottom_area: Area2D = %BottomArea

# For column spawning we'll need to follow these rules
# 1. Vertical offset must be within a 24px padding to ensure some part of pipe visible
# 2. Pipes gap must be between 3-4 times bird height
# 3. Constat horizontal spacing
# 4. Uniform scroll speed
# 5. Vertical position is random
# 5.1 Position will always be capped within treshold of previous to prevent impossible to cross gaps

var gap_size = 32.0

var enable_move = true

func _ready() -> void:
	_init_signals()
	_init_pipe_textures()
	_init_pipe_positions()


func _process(delta: float) -> void:
		if enable_move:
			position.x -= SPEED * delta


func _init_signals() -> void:
	gap_area.body_entered.connect(_on_player_scored)
	top_area.body_entered.connect(_on_player_hit)
	bottom_area.body_entered.connect(_on_player_hit)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_screen_exited)


func _init_pipe_textures() -> void:
	var texture : Texture2D
	match pipe_color:
		PipeColor.GREEN:
			texture = load(PIPE_PATH_GREEN)
		PipeColor.RED:
			texture = load(PIPE_PATH_RED)

	if not texture:
		push_error("Could not load pipe texture for " + pipe_color)
		return

	top_pipe.flip_v = true
	top_pipe.texture = texture
	bottom_pipe.texture = texture


func _init_pipe_positions() -> void:
	gap_size = randf_range(GAP_MIN, GAP_MAX)
	gap_collision.shape.size.y = gap_size

	var y_offset = PIPE_HALF_HEIGHT + (gap_size / 2)
	top.position.y = y_offset * -1
	bottom.position.y = y_offset


func _on_player_scored(body: Node2D) -> void:
	if not body is Player:
		return

	SignalBus.player_scored.emit()


func _on_player_hit(body: Node2D) -> void:
	if not body is Player:
		return

	enable_move = false
	SignalBus.player_hit.emit()


func _on_screen_exited() -> void:
	queue_free()
