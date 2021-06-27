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
onready var _pause = $CanvasLayer/PauseMenu
onready var _settings: UserDefaults

func _ready() -> void:
	_settings = UserDefaults.new()
	_setup_world()
	_setup_ui()
	_instantiate_music()
	_play_alarm()

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

func _dbg_animations() -> void:
	if not _settings.debug_mode: return
	_settings.animate_end_levels = not _settings.animate_end_levels
	print_debug("End Level Animations toggled %s" % ("ON" if _settings.animate_end_levels else "OFF"))
	var _exit = find_node("Exit*")
	if _exit == null: return
	_exit._update_animation(_settings.animate_end_levels)

func _dbg_fullbright() -> void:
	$LightsOff.visible = not $LightsOff.visible
	print_debug("Toggled fullbright %s" % ("ON" if not $LightsOff.visible else "OFF"))

func _dbg_skip() -> void:
	var _exit = find_node("Exit*")
	if _exit == null: return
	_exit._on_activate()

func _destroy_clone() -> void:
	if not _clone_exists(): return
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

func _exit_to_main() -> void:
	var _err = get_tree().change_scene("res://scenes/main.tscn")
	if _err != OK:
		push_error(_err)

func _find_all_inputs() -> Array:
	var inputs = []
	for node in get_children():
		if not node is AbstractInput: continue
		inputs.append(node)
	return inputs

func _find_all_objects() -> Array:
	var objects = []
	for node in get_children():
		if not node is MovableObject: continue
		objects.append(node)
	return objects

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

func _hud_connect_events() -> void:
	var _hud_err = _hud.connect("costume_request", self, "send_costume_request")
	_hud_err = _hud.connect("restart_level_request", self, "_restart_level")
	_hud_err = _hud.connect("update_field_of_view_request", self, "send_fov_request")
	if _hud_err:
		push_error(_hud_err)

func _hud_disable_tutorials() -> void:
	if not WALK_TUTORIAL:
		_hud.disable_tut_walk()
	if not COSTUME_TUTORIAL:
		_hud.disable_tut_costume()
	if not RESTART_TUTORIAL:
		_hud.disable_tut_restart()

func _hud_hide_unnecessary_components() -> void:
	_hud.disable_unused(ALLOWED_COSTUMES)
	if not _settings.show_mobile_controls:
		_hud.disable_mobile_ui()
	if not RESTARTABLE:
		_hud.disable_restart()
	_hud_disable_tutorials()

func _hud_update_fov() -> void:
	_hud.set_fov_bounds(_min_fov_bound)
	if not _settings.persist_field_of_view: return
	_hud.slider_fov.value = clamp(-_settings.field_of_view, -1 - _min_fov_bound, -_min_fov_bound)
	if _player != null:
		_player.FIELD_OF_VIEW = clamp(_settings.field_of_view, _min_fov_bound, _min_fov_bound + 1)

func _instantiate_clone() -> void:
	if _clone_exists():
		return
	_clone = _clone_data.instance()
	_clone.name = "Clone"
	_clone.global_position = _get_player().global_position
	add_child(_clone)

func _instantiate_debug() -> void:
	if not _settings.debug_mode: return
	if DEBUG_MODE:
		_enable_debug_player()
	
	var _exit = find_node("Exit*")
	if _exit == null: return
	_exit._update_animation(_settings.animate_end_levels)

func _instantiate_from_save() -> void:
	var _save = SaveUtils.new()
	if _save.save_exists():
		_save.load_from_file()
		if _save.state.current_level == get_tree().current_scene.filename:
			_resume_from_suspended_state(_save.state)
	_save.state = _suspend_to_state()
	_save.save_to_file()

func _instantiate_hud() -> void:
	_hud.visible = true
	_hud_hide_unnecessary_components()
	_hud_disable_tutorials()
	_hud_update_fov()
	_hud_connect_events()

func _instantiate_music() -> void:
	_bgm = AudioStreamPlayer.new() as AudioStreamPlayer
	add_child(_bgm)
	if MUSIC == 0: return
	
	_bgm.stream = _get_music_track()
	_bgm.bus = "Music"
	_bgm.play()

func _instantiate_objects() -> void:
	if _player == null:
		return
	for child in get_children():
		if not child is MovableObject: continue
		(child as MovableObject)._connect_to_player(_player)

func _instantiate_player() -> void:
	_player = _get_player()
	if _player == null:
		push_warning("Player is either missing or obstructed.")
	_min_fov_bound = _player.FIELD_OF_VIEW
	var _plyr_err = _player.connect("wants_clone", self, "toggle_clone")
	if _plyr_err != OK:
		push_error(_plyr_err)

func _pause_game() -> void:
	get_tree().paused = true
	_pause.visible = true

func _play_alarm() -> void:
	var _alarm = AudioStreamPlayer2D.new()
	_alarm.global_position = _player.global_position + Vector2(128, 0)
	_alarm.stream = load("res://assets/sfx/alarmDisable.ogg")
	_alarm.autoplay = true
	_alarm.bus = "SFX"
	(_alarm.stream as AudioStreamOGGVorbis).loop = false
	_alarm.connect("finished", _alarm, "queue_free")
	add_child(_alarm)

func _restart_level() -> void:
	var _err = get_tree().reload_current_scene()
	if _err != OK:
		push_error(_err)

func _resume_from_suspended_state(save_file: SaveState) -> void:
	_player.global_position = save_file.player_position
	_player.change_costume(save_file.player_costume)
	for input in _find_all_inputs():
		var _frozen = save_file.inputs[input.get_name()]
		input._active = _frozen["active"]
	for object in _find_all_objects():
		object.global_position = save_file.movable_objects[object.name]

func _setup_world() -> void:
	_instantiate_player()
	_instantiate_objects()
	_instantiate_from_save()

func _setup_ui() -> void:
	_instantiate_hud()
	_instantiate_debug()

func _suspend_to_state() -> SaveState:
	var state = SaveState.new()
	state.current_level = get_tree().current_scene.filename
	state.player_costume = _player.CURRENT_COSTUME
	state.player_position = _player.global_position
	state.save_input_states(_find_all_inputs())
	state.save_movable_objects(_find_all_objects())
	return state

func _unhandled_input(event: InputEvent) -> void:
	if event.get_action_strength("dbg_skip_level") and _settings.debug_mode:
		_dbg_skip()
	elif event.get_action_strength("dbg_toggle_fullbright") and _settings.debug_mode:
		_dbg_fullbright()
	elif event.get_action_strength("dbg_toggle_animation") and _settings.debug_mode:
		_dbg_animations()
	elif event.get_action_strength("ui_pause"):
		_pause_game()
