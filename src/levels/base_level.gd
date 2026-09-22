extends Node2D
class_name BaseLevel

@onready var day: Sprite2D = %Day
@onready var night: Sprite2D = %Night
@onready var landscape: Parallax2D = %Landscape
@onready var ground: Parallax2D = %Ground

@onready var player_spawner: Spawner = %PlayerSpawner
@onready var pipe_spawner: Spawner = %PipeSpawner

@onready var world_boundary_top: Area2D = %WorldBoundaryTop
@onready var world_boundary_bottom: Area2D = %WorldBoundaryBottom

@export var level_type = LevelType.DAY
@export var bg_speed = 20.0
@export var fg_speed = 50.0

enum LevelType {
	DAY,
	NIGHT,
}


func _ready() -> void:
	world_boundary_top.body_entered.connect(_on_world_boundary_enter)
	world_boundary_bottom.body_entered.connect(_on_world_boundary_enter)

	if level_type == LevelType.DAY:
		day.visible = true
		night.visible = false
	else:
		day.visible = false
		night.visible = true

	landscape.autoscroll.x = bg_speed * -1
	ground.autoscroll.x = fg_speed * -1


func _on_world_boundary_enter(body: Node2D) -> void:
	if not body is Player:
		return

	SignalBus.player_hit.emit()


func get_player_spawn() -> Vector2:
	return player_spawner.global_position


func get_pipes_spawn() -> Vector2:
	return pipe_spawner.global_position
