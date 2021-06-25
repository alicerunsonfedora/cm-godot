class_name GDConfineScript
extends Area2D

onready var _audio = $Alert as AudioStreamPlayer2D

var _alerted_once: bool = false
var _listening_for_keypress = false
var _should_console_print: bool = false

func _ready() -> void:
	var _settings = UserDefaults.new()
	_should_console_print = _settings.debug_mode
	var _err = connect("body_entered", self, "_on_body_entered")
	_err = connect("body_exited", self, "_on_body_exited")
	if _err != OK:
		push_error("%s" % _err)

func _confine_spaces() -> void:
	_warning(tr("GD_CONFINE_WARNING_ONCE" if not _alerted_once else "GD_CONFINE_WARNING_ALL"))
	if not _alerted_once:
		_alerted_once = true
	_audio.pitch_scale = clamp(randf(), 0.9, 1.0)
	_audio.play()

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	body.update_player_hint(Player.PlayerHint.INTERACT)
	_listening_for_keypress = true

func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	body.update_player_hint(Player.PlayerHint.NONE)
	_listening_for_keypress = false

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.get_action_strength("interact") and _listening_for_keypress:
		_confine_spaces()

func _warning(message: String) -> void:
	if _should_console_print:
		print(message)
	print_debug(message)