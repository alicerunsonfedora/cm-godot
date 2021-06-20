# universe.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A base class that handles all world events, from music to map configurations.
class_name Universe
extends Node2D

# An enumeration of the different music tracks that can be played.
enum Track {
	NONE = 0,
	MINUTE = 1,
	PHASE = 2,
	DISTURBANCE = 3,
	WATCH_YOUR_STEP = 4,
	RANDOM = 5
}

# The track to play in this level.
export(Track) var MUSIC = 0

# Whether to allow costume switching.
export(bool) var MULTIPLE_COSTUMES = true

# A list of costume types to switch to in this level.
export(Array, Player.CostumeType) var ALLOWED_COSTUMES = []

# Whether to display the debug menu in the HUD.
# If enabled, the only costume available will be ALL.
export(bool) var DEBUG_MODE = false

# Whether to allow the player to restart.
export(bool) var RESTARTABLE = true

# Whether to show the tutorial for moving around the environment.
export(bool) var WALK_TUTORIAL = false

# Whether to show the tutorial for switching costumes.
export(bool) var COSTUME_TUTORIAL = false

# Whether to show the tutorial for restarting a level.
export(bool) var RESTART_TUTORIAL = false


# A signal emitted when the player lock has been requested and granted.
signal request_player_lock()

# A signal emitted when the player lock has been released.
signal release_player_lock()

var _lock: bool = false
var _min_fov_bound = 0.0

onready var _bgm: AudioStreamPlayer
onready var _clone_data = load("res://nodes/obj_clone.tscn")
onready var _clone: Node2D
onready var _hud: HUD = $CanvasLayer/HUD as HUD
onready var _player: Player
onready var _settings: UserDefaults

func _ready() -> void:
	_settings = UserDefaults.new()
	_player = _get_player()
	if _player == null:
		push_warning("Player is either missing or obstructed.")
	_min_fov_bound = _player.FIELD_OF_VIEW
	var _plyr_err = _player.connect("wants_clone", self, "toggle_clone")
	if _plyr_err != OK:
		push_error(_plyr_err)
	
	_instantiate_music()
	_instantiate_hud()
	_instantiate_objects()

	if DEBUG_MODE:
		_enable_debug_player()
		_hud.hide_debug_menu()

# Send a request to the player to change the costume if applicable or allowed by the universe.
# Parameters:
# 	costume_type: An integer representing the costume to request switching to.
func send_costume_request(costume_type: int) -> void:
	if _player == null or not MULTIPLE_COSTUMES or ALLOWED_COSTUMES.find(costume_type) == -1:
		return
	_player.change_costume(costume_type)

# Send a request to the player to update the field of view.
# Parameters:
# 	fov: The field of view factor to update the player's field of view to.
func send_fov_request(fov: float) -> void:
	_player.FIELD_OF_VIEW = fov
	_settings.field_of_view = fov

# Toggle the player clone in the universe.
func toggle_clone() -> void:
	if _player == null or _player.CURRENT_COSTUME != Player.CostumeType.FLASH_DRIVE:
		return
	if _clone_exists():
		_destroy_clone()
		return
	_instantiate_clone()

# Trigger the locking mechanism for the player.
# This is used to handle any UI elements that require that the player be static, such as cutscenes.
# NOTE: The _lock check is written the way it is because the language server is unable to verify that the signals are
# 	being emitted correctly.
func trigger_lock() -> void:
	if _lock:
		emit_signal("release_player_lock")
	else:
		emit_signal("request_player_lock")
	_lock = not _lock

# Returns whether a clone exists in the universe.
func _clone_exists() -> bool:
	return _clone != null

func _destroy_clone() -> void:
	if not _clone_exists():
		return
	remove_child(_clone)
	_clone.queue_free()
	_clone = null

func _enable_debug_player():
	if _player == null:
		push_error("Player is missing from the scene.")
		return
	_player.change_costume(4)
	MULTIPLE_COSTUMES = false
	ALLOWED_COSTUMES = [4]

func _get_music_track() -> AudioStream:
	if MUSIC == Track.RANDOM:
		print_debug("A random song will be picked.")
		MUSIC = randi() % 4
	match MUSIC:
		Track.MINUTE:
			return load("res://assets/bgm/minute.ogg") as AudioStreamOGGVorbis
		Track.DISTURBANCE:
			return load("res://assets/bgm/disturbance.ogg") as AudioStreamOGGVorbis
		Track.WATCH_YOUR_STEP:
			return load("res://assets/bgm/watchyourstep.ogg") as AudioStreamOGGVorbis
		Track.PHASE:
			return load("res://assets/bgm/phase.ogg") as AudioStreamOGGVorbis
		_:
			push_warning("Received unexpected music type or none.")
			return AudioStream.new()

func _get_player() -> Player:
	return find_node("Player") as Player

func _instantiate_clone() -> void:
	if _clone_exists():
		return
	_clone = _clone_data.instance()
	_clone.global_position = _get_player().global_position
	add_child(_clone)

func _instantiate_hud() -> void:
	_hud.visible = true
	_hud.disable_unused(ALLOWED_COSTUMES)

	if not _settings.show_mobile_controls:
		_hud.disable_mobile_ui()

	if not RESTARTABLE:
		_hud.disable_restart()

	if not WALK_TUTORIAL:
		_hud.disable_tut_walk()
	if not COSTUME_TUTORIAL:
		_hud.disable_tut_costume()
	if not RESTART_TUTORIAL:
		_hud.disable_tut_restart()

	_hud.set_fov_bounds(_min_fov_bound)
	if _settings.persist_field_of_view:
		_hud.slider_fov.value = clamp(-_settings.field_of_view, -1 - _min_fov_bound, -_min_fov_bound)
		if _player != null:
			_player.FIELD_OF_VIEW = clamp(_settings.field_of_view, _min_fov_bound, _min_fov_bound + 1)

	var _hud_err = _hud.connect("costume_request", self, "send_costume_request")
	_hud_err = _hud.connect("restart_level_request", self, "_restart_level")
	_hud_err = _hud.connect("update_field_of_view_request", self, "send_fov_request")
	if _hud_err:
		push_error(_hud_err)

func _instantiate_music() -> void:
	_bgm = AudioStreamPlayer.new() as AudioStreamPlayer
	add_child(_bgm)
	if not _settings.allow_music or MUSIC == 0: return
	
	_bgm.stream = _get_music_track()
	_bgm.volume_db = -0.6
	_bgm.play()

func _instantiate_objects() -> void:
	if _player == null:
		return
	for child in get_children():
		if not child is MovableObject: continue
		(child as MovableObject)._connect_to_player(_player)

func _restart_level() -> void:
	var _err = get_tree().reload_current_scene()
	if _err != OK:
		push_error(_err)
