extends CharacterBody2D

@onready var _visuals: AnimatedSprite2D = %Visuals
@onready var _audio: AudioStreamPlayer = %Audio

@export var bird_sprite = BirdSprite.BLUE
@export var sfx_streams: Dictionary[SFX, AudioStream]

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ROTATION_SPEED = 1

enum SFX {
	DIE,
	HIT,
	POINT,
	SWOOSH,
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
	# Init animation
	_visuals.animation = BirdSprite.keys()[bird_sprite]
	_visuals.pause()


func _physics_process(delta: float) -> void:
	# We always add gravity.
	velocity += get_gravity() * delta
	
	# For rotation of sprite calculation will be done based on velocity.y
	# constrained to +-90deg (180deg total). For this we'll use JUMP_VELOCITY as
	# our max velicty.y, as we need it to map linear velocity into rotation

	var currentRotation = rotation
	var normalized_vy = minf(maxf(velocity.y / JUMP_VELOCITY, -1), 1)
	var targetRotation = normalized_vy * (PI / 2)
	rotation = lerp_angle(
		currentRotation, 
		targetRotation, 
		ROTATION_SPEED * delta
	)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_just_pressed("ok") and _action != Action.JUMP:
		_do_action(Action.JUMP)


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
	_play_sfx(SFX.SWOOSH)
	

func _die() -> void:
	_play_sfx(SFX.HIT)
	_play_sfx(SFX.DIE)
	SignalBus.player_hit.emit()


func _play_sfx(sfx: SFX) -> void:
	var stream = sfx_streams.get(sfx) as AudioStream
	if not sfx:
		return
		
	var playback = _audio.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if not playback:
		return

	playback.play_stream(stream)
