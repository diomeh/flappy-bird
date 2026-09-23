extends Node

const PLAYER_SCENE	 = preload("res://src/gameplay/player/player.tscn")
const LEVEL_SCENE	 = preload("res://src/levels/base_level.tscn")

const PLAYER_SCENE_PATH	 = "res://src/gameplay/player/player.tscn"
const LEVEL_SCENE_PATH	 = "res://src/levels/base_level.tscn"

@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var pipe_spawner: PipeSpawner = %PipeSpawner

var player: Player

var _current_level: BaseLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_player()
	load_level(LEVEL_SCENE_PATH)
	# We need to wait for level to be ready before spawning pipes
	_init_systems.call_deferred()


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event.is_action_pressed("ui_cancel"):
		quit_game()


## Called to quit the application
## Propagates the close request notification to every node, and then quits the application
func quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _init_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_SCENE_PATH) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_PATH)
		return

	var player_instance : Node = PLAYER_SCENE.instantiate()
	if not player_instance:
		push_error("Could not instantiate player scene " + PLAYER_SCENE_PATH)
		return

	if player_instance is not Player:
		player_instance.free() # Node must be freed to avoid unreferenced orphan nodes
		push_error("Loaded player scene is not of type Player " + PLAYER_SCENE_PATH)
		return

	player = player_instance as Player
	entity_root.add_child(player)


func load_level(level_scene_path : String) -> void:
	# Make sure this is called during idle time
	_perform_level_load.call_deferred(level_scene_path)


func _perform_level_load(level_scene_path : String) -> void:
	if is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null
		# Wait to allow the queued deletion to process so it is out of the scene tree
		await get_tree().process_frame

	var new_level_packed : PackedScene = (
			ResourceLoader.load(level_scene_path, "PackedScene") as PackedScene
	)

	if new_level_packed == null:
		push_error("Could not load level as a packed scene: " + level_scene_path)
		return

	var new_level : Node = new_level_packed.instantiate()

	if not new_level:
		push_error("Could not instantiate new level " + level_scene_path)
		return

	if new_level is not BaseLevel:
		new_level.free()  # Level must be freed to avoid unreferenced orphan nodes
		push_error("Loaded level is not of type BaseLevel " + level_scene_path)
		return

	_current_level = new_level as BaseLevel

	level_root.add_child(_current_level)

	_place_player_at_level_spawn()


## Finds the default spawn location in currently loaded level, and places
##  the Player at that position.
func _place_player_at_level_spawn() -> void:
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if _current_level == null:
		push_error("Cannot place player into level because level is null")
		return

	player.global_position = _current_level.get_player_spawn_point()


func _init_systems() -> void:
	pipe_spawner.configure(
		_current_level.get_pipe_spawn_point(),
		entity_root
	)
	pipe_spawner.schedule_spawn()
