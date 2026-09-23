extends Node
class_name PipeSpawner

const MAX_HEIGHT = 512.0
const FLOOR_HEIGHT = 112.0 # Taken from floor sprite

const PIPE_MIN_PADDING = 24.0 + 60.0
const PIPE_PADDING_TOP = PIPE_MIN_PADDING
const PIPE_PADDING_BOTTOM = MAX_HEIGHT - PIPE_MIN_PADDING - FLOOR_HEIGHT

const PIPE_SCENE	 = preload("res://src/gameplay/pipe/pipe_column.tscn")

@onready var timer: Timer = %Timer

@export var spawn_time = 1.8

var _spawn_point: Vector2
var _target_node: Node2D
var _recurrent = true


func _ready() -> void:
	timer.wait_time = spawn_time
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(spawn)


func configure(
	spawn_point: Vector2,
	target_node: Node2D,
	is_recurrent: bool = true
) -> void:
	_spawn_point = spawn_point
	_target_node = target_node
	_recurrent = is_recurrent


func schedule_spawn() -> void:
	spawn()
	timer.start()


func spawn() -> void:
	var pipe := PIPE_SCENE.instantiate() as PipeColumn
	if not pipe:
		push_error("Could not instantiate pipe scene")
		return

	var spawn_point = _spawn_point
	spawn_point.y = randf_range(PIPE_PADDING_TOP, PIPE_PADDING_BOTTOM)

	pipe.global_position = spawn_point
	_target_node.add_child(pipe)
