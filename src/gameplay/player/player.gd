extends CharacterBody2D
class_name Player

@onready var _visuals: AnimatedSprite2D = %Visuals
@onready var _audio: AudioStreamPlayer = %Audio

@export var bird_sprite = BirdSprite.BLUE
@export var sfx_streams: Dictionary[SFX, AudioStream]

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ROTATION_SPEED = 10

enum SFX {
	DIE,
	HIT,
	POINT,
	SWOOSH, # FIXME: Not sure where to use this one
	WING
}

enum BirdSprite {
	BLUE,
	RED,
	YELLOW,
}

enum Action {
	GLIDE,
	JUMP,
	DIE,
}

var _action = Action.GLIDE


func _ready() -> void:
	SignalBus.player_hit.connect(_on_player_hit)
	
	# Init animation
	var sprite_name: String = BirdSprite.keys()[bird_sprite]
	_visuals.animation = sprite_name.to_lower()
	_visuals.pause()


func _physics_process(delta: float) -> void:
	# We always add gravity.
	velocity += get_gravity() * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ok") and _action != Action.JUMP:
		_do_action(Action.JUMP)
	
	# For rotation of sprite calculation will be done based on velocity.y
	# constrained to +-90deg (180deg total). For this we'll use JUMP_VELOCITY as
	# our max velicty.y, as we need it to map linear velocity into rotation

	var currentRotation = rotation
	var normalized_vy = minf(maxf(velocity.y / JUMP_VELOCITY, -1), 1)
	var targetRotation = normalized_vy * (PI / 2) * -1
	rotation = lerp_angle(
		currentRotation, 
		targetRotation, 
		ROTATION_SPEED * delta
	)

	move_and_slide()


func _do_action(action: Action) -> void:
	match action:
		Action.GLIDE:
			return
		Action.JUMP:
			_jump()
		Action.DIE:
			_die()
			

func _jump() -> void:
	velocity.y = JUMP_VELOCITY
	_play_sfx(SFX.WING)


func _die() -> void:
	_play_sfx(SFX.HIT)
	_play_sfx(SFX.DIE)


func _play_sfx(sfx: SFX) -> void:
	var stream = sfx_streams.get(sfx) as AudioStream
	if not stream:
		printerr("Failed to obtain stream ", sfx)
		return
		
	if not _audio.has_stream_playback():
		_audio.play()
		
	var playback = _audio.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if not playback:
		printerr("Failed to obtain stream playback")
		return

	playback.play_stream(stream)


func _on_player_hit() -> void:
	_do_action(Action.DIE)
