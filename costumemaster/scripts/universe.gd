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

# A signal emitted when the player lock has been requested and granted.
signal request_player_lock()

# A signal emitted when the player lock has been released.
signal release_player_lock()

var _lock: bool = false

onready var _bgm: AudioStreamPlayer
onready var _hud: HUD = $CanvasLayer/HUD as HUD

func _ready() -> void:
	_bgm = AudioStreamPlayer.new() as AudioStreamPlayer
	add_child(_bgm)
	if MUSIC > 0:
		_bgm.stream = _get_music_track()
		_bgm.play()

	_hud.visible = true
	var _hud_err = _hud.connect("costume_request", self, "send_costume_request")
	if _hud_err:
		push_error(_hud_err)

	if DEBUG_MODE:
		_enable_debug_player()
		_hud.hide_debug_menu()



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

func _enable_debug_player():
	var player = find_node("Player") as Player
	if player == null:
		push_error("Player is missing from the scene.")

	player.change_costume(4)
	MULTIPLE_COSTUMES = false
	ALLOWED_COSTUMES = [4]

# Trigger the locking mechanism for the player.
# This is used to handle any UI elements that require that the player be static, such as cutscenes.
func trigger_lock() -> void:
	if _lock:
		emit_signal("release_player_lock")
	else:
		emit_signal("request_player_lock")
	_lock = not _lock

# Send a request to the player to change the costume if applicable or allowed by the universe.
# Parameters:
# 	costume_type: An integer representing the costume to request switching to.
func send_costume_request(costume_type: int) -> void:
	var player_node = find_node("Player")
	if player_node == null or not MULTIPLE_COSTUMES or ALLOWED_COSTUMES.find(costume_type) == -1:
		return
	(player_node as Player).change_costume(costume_type)
