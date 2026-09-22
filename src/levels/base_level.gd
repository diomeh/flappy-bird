extends Node2D
class_name BaseLevel

@onready var day: Sprite2D = %Day
@onready var night: Sprite2D = %Night
@onready var landscape: Parallax2D = %Landscape
@onready var ground: Parallax2D = %Ground

# Spawners
@onready var player_spawner: Spawner = %PlayerSpawner
@onready var pipe_spawner_top: Spawner = %PipeSpawnerTop
@onready var pipe_spawner_bottom: Spawner = %PipeSpawnerBottom

@onready var world_boundary: Area2D = %WorldBoundary

@export var level_type = LevelType.DAY
@export var bg_speed = 20.0
@export var fg_speed = 50.0

enum LevelType {
	DAY,
	NIGHT,
}


func _ready() -> void:
	world_boundary.body_exited.connect(_on_world_boundary_exit)
	
	if level_type == LevelType.DAY:
		day.visible = true
		night.visible = false
	else:
		day.visible = false
		night.visible = true
	
	landscape.autoscroll.x = bg_speed * -1
	ground.autoscroll.x = fg_speed * -1


func _on_world_boundary_exit(body: Node2D) -> void:
	if not body is Player:
		return

	SignalBus.player_hit.emit() 


func get_player_spawn() -> Vector2:
	return player_spawner.global_position


func get_pipes_spawns() -> Array[Vector2]:
	return [
		pipe_spawner_top.global_position,
		pipe_spawner_bottom.global_position,
	]
