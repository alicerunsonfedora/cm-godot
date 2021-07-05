# player.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
class_name Player
extends KinematicBody2D

# An enumeration for all of the different costume types.
enum CostumeType {
	DEFAULT = 0,
	FLASH_DRIVE = 1,
	SWIFT_BIRD = 2,
	MAGIC = 3,
	ALL = 4
}

# An enumeration for all of the different player hints that can be displayed.
enum PlayerHint {
	NONE = 0,
	INTERACT = 1,
	EXIT = 2,
	NEEDS_INPUT = 3,
	HOLDING_ITEM = 4
}

# The player's default mass.
export var MASS = 1.0

# The maximum speed the player can reach.
export var MAX_SPEED = 1000

# The amount of friction that the player experiences.
export var FRICTION = 100

# The player's default field of view.
export var FIELD_OF_VIEW = 1.0 setget _update_player_camera

# The player's current costume.
export(CostumeType) var CURRENT_COSTUME = CostumeType.DEFAULT setget change_costume_editor

signal wants_clone()
signal wants_drop()
signal wants_pickup()

const acceleration = 250
const speed = 500

var _actual_mass = MASS
var _can_move = true
var _collision_velocity = Vector2.ZERO
var _has_item = false
var _hint = PlayerHint.NONE
var _mobile_movement = Vector2.ZERO
var _near_item = false
var _velocity = Vector2.ZERO

onready var _asm = $AnimationStateTree as AnimationTree
onready var _aState = _asm.get("parameters/playback") as AnimationNodeStateMachinePlayback
onready var _audio = $Voicebox as AudioStreamPlayer2D
onready var _camera = $Camera as Camera2D
onready var _hint_gui = $Hint as Sprite
onready var _sprite = $Sprite as Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FIELD_OF_VIEW != null:
		_camera.zoom = Vector2(FIELD_OF_VIEW, FIELD_OF_VIEW)
	change_costume(CURRENT_COSTUME)

# Change the player's current costume and reload the sprite's texutre to match.
# Parameters:
# 	costume_type: An integer representing the costume that the player should wear.
func change_costume(costume_type: int) -> void:
	CURRENT_COSTUME = costume_type
	if _sprite != null:
		_sprite.texture = load("res://assets/sprites/" + _costume_name() + ".png")
	_update_player_mass()
	_update_player_bit_mask()

# Change the player's costume in the editor window.
func change_costume_editor(type) -> void:
	CURRENT_COSTUME = type
	if Engine.editor_hint:
		var sprite_node = get_node("Sprite")
		if sprite_node:
			sprite_node.texture = load("res://assets/sprites/" + _costume_name() + ".png")

# Toggle the player's item detection.
# This should be called by methods that want to inform the player that they can be picked up.
func toggle_item_detection(value: bool) -> void:
	_near_item = value

# Update the player UI hint.
# Parameters:
#	status: The integer representing the player hint to display.
func update_player_hint(status: int) -> void:
	var _light = $Hint/Light2D
	_hint_gui.visible = status != PlayerHint.NONE
	_light.visible = status != PlayerHint.NONE
	_hint = status
	match _hint:
		PlayerHint.INTERACT:
			_hint_gui.frame_coords = Vector2(4, 4)
		PlayerHint.EXIT:
			_hint_gui.frame_coords = Vector2(10, 4)
		PlayerHint.NEEDS_INPUT:
			_hint_gui.frame_coords = Vector2(7, 6)
		PlayerHint.HOLDING_ITEM:
			_hint_gui.frame_coords = Vector2(6, 6)
		PlayerHint.NONE, _:
			_hint_gui.frame_coords = Vector2(0, 0)

func _block_movement():
	_can_move = false

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

func _get_movement_vector() -> Vector2:
    if _mobile_movement != Vector2.ZERO:
			return _mobile_movement
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return move_vector.normalized()

func _physics_process(delta) -> void:
	if Engine.editor_hint: return
	var move_vector = _get_movement_vector()
	
	if move_vector != Vector2.ZERO and _can_move:
		_walk_start(move_vector)
		_velocity += move_vector * acceleration * _actual_mass * delta
		_velocity = _velocity.clamped(MAX_SPEED * _actual_mass * delta)
	else:
		_walk_stop()
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_collision_velocity = move_and_slide(_velocity * delta * speed)

func _play_cant_use_sound() -> void:
	var streamer = AudioStreamPlayer2D.new()
	streamer.connect("finished", streamer, "queue_free")
	add_child(streamer)
	streamer.pitch_scale = 1
	streamer.stream = load("res://assets/sfx/cantUse.ogg") as AudioStreamOGGVorbis
	streamer.stream.loop = false
	streamer.bus = "SFX"
	streamer.play()

func _start_footsteps() -> void:
	if _audio.playing: return
	_audio.stream = load("res://assets/sfx/565479-aelstraz-footstep-wood-co.ogg") as AudioStreamOGGVorbis
	_audio.stream.loop = true
	_audio.play()

func _stop_footsteps() -> void:
	if not _audio.playing: return
	_audio.stop()
	_audio.stream = null

func _unblock_movement():
	_can_move = true

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.get_action_strength("interact") and not _has_item and _near_item:
		emit_signal("wants_pickup")
	elif event.get_action_strength("interact") and _has_item:
		emit_signal("wants_drop")
	elif event.get_action_strength("interact") and _hint == PlayerHint.NONE:
		_play_cant_use_sound()
	elif event.get_action_strength("clone"):
		emit_signal("wants_clone")

func _update_mobile_movement(new_value: Vector2) -> void:
		_mobile_movement = new_value

func _update_player_camera(value: float):
	FIELD_OF_VIEW = value
	if _camera != null:
		_camera.zoom = Vector2(value, value)

func _update_player_bit_mask() -> void:
	if CURRENT_COSTUME == CostumeType.SWIFT_BIRD:
		set_collision_mask_bit(3, true)
		set_collision_mask_bit(0, false)
		return
	set_collision_mask_bit(0, true)
	set_collision_mask_bit(3, false)

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

func _walk_start(move_vector: Vector2) -> void:
	_asm.set("parameters/idle/blend_position", move_vector)
	_asm.set("parameters/walk/blend_position", move_vector)
	_aState.travel("walk")
	_start_footsteps()
	if _audio.playing:
		_audio.pitch_scale = clamp(randf(), 0.5, 1.0)

func _walk_stop() -> void:
	_aState.travel("idle")
	_stop_footsteps()
