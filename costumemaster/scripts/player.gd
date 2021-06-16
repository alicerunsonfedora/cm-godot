tool
class_name Player
extends KinematicBody2D

enum CostumeType {
	DEFAULT = 0,
	FLASH_DRIVE = 1,
	SWIFT_BIRD = 2,
	MAGIC = 3,
	ALL = 4
}

enum PlayerHint {
	NONE = 0,
	INTERACT = 1,
	EXIT = 2,
	NEEDS_INPUT = 3
}

# The player's default mass.
export var MASS = 1.0

# The maximum speed the player can reach.
export var MAX_SPEED = 1000

# The amount of friction that the player experiences.
export var FRICTION = 100

# The player's default field of view.
export var FIELD_OF_VIEW = 1.0

# The player's current costume.
export(CostumeType) var CURRENT_COSTUME = CostumeType.DEFAULT setget change_costume_editor

signal wants_clone()

const speed = 500
const acceleration = 250

var _velocity = Vector2.ZERO
var _collision_velocity = Vector2.ZERO
var _can_move = true
var _hint = PlayerHint.NONE
var _actual_mass = MASS

onready var _sprite = $Sprite as Sprite
onready var _asm = $AnimationStateTree as AnimationTree
onready var _camera = $Camera as Camera2D
onready var _aState = _asm.get("parameters/playback") as AnimationNodeStateMachinePlayback
onready var _hint_gui = $Hint as Sprite
onready var _audio = $Voicebox as AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the scale factor to the FOV.
	if FIELD_OF_VIEW != null:
		_camera.zoom = Vector2(FIELD_OF_VIEW, FIELD_OF_VIEW)

	# Change the costume immediately.
	change_costume(CURRENT_COSTUME)

# Returns the resource name for the costume.
func _costume_name() -> String:
	match CURRENT_COSTUME:
		CostumeType.DEFAULT:
			return "default"
		CostumeType.FLASH_DRIVE:
			return "flash"
		CostumeType.SWIFT_BIRD:
			return "bird"
		CostumeType.MAGIC:
			return "pony"
		CostumeType.ALL:
			return "megacostume"
	return "none"

# Returns the default acceleration for the player.
func _default_acceleration() -> int:
	return 250

# Change the player's current costume and reload the sprite's texutre to match.
# Parameters:
# 	costume_type: An integer representing the costume that the player should wear.
func change_costume(costume_type: int) -> void:
	CURRENT_COSTUME = costume_type
	if _sprite != null:
		_sprite.texture = load("res://assets/sprites/" + _costume_name() + ".png")
	_update_player_mass()

# Change the player's costume in the editor window.
func change_costume_editor(type) -> void:
	CURRENT_COSTUME = type
	if Engine.editor_hint:
		var sprite_node = get_node("Sprite")
		if sprite_node:
			sprite_node.texture = load("res://assets/sprites/" + _costume_name() + ".png")

# Update the player UI hint.
# Parameters:
#	status: The integer representing the player hint to display.
func update_player_hint(status: int) -> void:
	_hint = status
	match _hint:
		PlayerHint.INTERACT:
			_hint_gui.visible = true
			_hint_gui.frame_coords = Vector2(4, 4)
		PlayerHint.EXIT:
			_hint_gui.visible = true
			_hint_gui.frame_coords = Vector2(10, 4)
		PlayerHint.NEEDS_INPUT:
			_hint_gui.visible = true
			_hint_gui.frame_coords = Vector2(7, 6)
		PlayerHint.NONE, _:
			_hint_gui.visible = false


func _physics_process(delta) -> void:
	if Engine.editor_hint:
		return

	# Create a blank vector that represents our movement.
	var move_vector = Vector2.ZERO

	# Determine the changes based on movement inputs.
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# Normalize to ensure that movement is equally distributed.
	move_vector = move_vector.normalized()

	# If we are moving, update our velocity and clamp it to our max speed with respect to delta time
	# and the mass.
	if move_vector != Vector2.ZERO and _can_move:
		_asm.set("parameters/idle/blend_position", move_vector)
		_asm.set("parameters/walk/blend_position", move_vector)

		_aState.travel("walk")

		_velocity += move_vector * acceleration * _actual_mass * delta
		_velocity = _velocity.clamped(MAX_SPEED * _actual_mass * delta)

	# Otherwise, update our velocity to move towards zero with respect to delta time and friction.
	else:
		_aState.travel("idle")
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Move the player with the new velocity with respect to any collidable objects.
	_collision_velocity = move_and_slide(_velocity * delta * speed)

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.get_action_strength("interact") and _hint == PlayerHint.NONE:
		_play_cant_use_sound()
	elif event.get_action_strength("clone"):
		emit_signal("wants_clone")

func _play_cant_use_sound() -> void:
	_audio.stream = load("res://assets/sfx/cantUse.ogg") as AudioStreamOGGVorbis
	_audio.stream.loop = false
	_audio.play()

func _update_player_mass() -> void:
	match CURRENT_COSTUME:
		CostumeType.ALL:
			_actual_mass = MASS * 0.65
		CostumeType.FLASH_DRIVE:
			_actual_mass = MASS * 0.9
		CostumeType.SWIFT_BIRD:
			_actual_mass = MASS * 1.2
		_:
			_actual_mass = MASS

func _block_movement():
	_can_move = false

func _unblock_movement():
	_can_move = true
