# A class that handles input from the player to send a signal to an output device.
# Examples of inputs that use this class are the lever, computer, and padlock.
class_name AbstractInput
extends Area2D

# The type of input interaction required to activate or deactivate the input.
export(int, "Interact Key", "Collision", "Both") var INTERACTION = 0

# The duration of the input. If set to `0`, this will activate permanently.
export var DURATION: float = 0.0

# Whether the input remains activated after being activated once.
export var PERMANENT: bool = true

# Whether the input is currently active.
var _active: bool = false

# Whether the input is listening for a key press to activate.
var _listening_for_keypress = false

# Whether the device has been permanently activated.
var _permalock = false

# The input's internal timer.
onready var timer: Timer

onready var _audio: AudioStreamPlayer2D

# A signal that emits when the input is activated.
signal input_active(name)

# A signal that emits when the input is deactivated.
signal input_inactive(name)

# Returns whether the input is currently active.
func active() -> bool:
	return _active

# Returns a unique name for the input.
# If the name has not been changed in the scene tree, the instance ID will be used.
func get_name() -> String:
	if name == "AbstractInput":
		return "AbstractInput_%s" % get_instance_id()
	return name

func _ready() -> void:
	_make_timer()
	_make_audio_player()
	var _ent_err = connect("body_entered", self, "_on_body_entered")
	var _exi_err = connect("body_exited", self, "_on_body_exited")

	if _ent_err != OK:
		print_debug(_ent_err)
	if _exi_err != OK:
		print_debug(_exi_err)

func _process(_delta) -> void:
	if Input.get_action_strength("interact") and _listening_for_keypress:
		if _active and not _permalock and (timer.time_left == 0):
			_deactivate()
		else:
			_activate()

func _make_timer() -> void:
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = DURATION if DURATION > 0 else 1.0
	add_child(timer)
	var _tim_con = timer.connect("timeout", self, "_deactivate")
	if _tim_con != OK:
		print_debug(_tim_con)

func _make_audio_player() -> void:
	_audio = AudioStreamPlayer2D.new()
	if DURATION > 0:
		_audio.stream = load("res://assets/sfx/alarmEnable.ogg") as AudioStreamOGGVorbis
	else:
		_audio.stream = load("res://assets/sfx/leverToggle.ogg") as AudioStreamOGGVorbis
	_audio.stream.loop = false
	add_child(_audio)

func _make_audio_tick() -> void:
	if _audio == null:
		_make_audio_player()
	_audio.stream = load("res://assets/sfx/alarmTick.ogg") as AudioStreamOGGVorbis
	_audio.stream.loop = true
	_audio.stream.loop_offset = 0

func _make_audio_turnoff() -> void:
	if _audio == null:
		_make_audio_player()
	if DURATION == 0:
		return
	_audio.stream = load("res://assets/sfx/alarmDisable.ogg") as AudioStreamOGGVorbis
	_audio.stream.loop = false

# Activate the input device.
# If the duration is a non-zero value, the internal timer will start.
func _activate() -> void:
	if _permalock or _active:
		return
	_active = true
	_on_activate()
	emit_signal("input_active", get_name())
	_audio.play()
	if PERMANENT:
		_permalock = true
	if DURATION > 0:
		timer.start()
		_make_audio_tick()
		_audio.play()

# Deactivate the input device.
# If the duration is a non-zero value, the internal timer will stop.
func _deactivate() -> void:
	_active = false
	_on_deactivate()
	emit_signal("input_inactive", get_name())
	_make_audio_turnoff()
	_audio.play()
	if DURATION > 0:
		timer.stop()

func _on_body_entered(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"]:
		return

	if INTERACTION % 2 == 0:
		_listening_for_keypress = true
		if body.name == "Clone":
			return
		(body as Player).update_player_hint(1)
	elif not _active:
		_activate()

func _on_body_exited(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"]:
		return
	if INTERACTION % 2 == 0:
		_listening_for_keypress = false
		if body.name == "Clone":
			return
		(body as Player).update_player_hint(0)
	elif _active:
		_deactivate()

# Run post-activation methods and calls. This may be overridden in other classes.
func _on_activate() -> void:
	pass

# Run post-deactivation methods and calls. This may be overridden in other classes.
func _on_deactivate() -> void:
	pass
