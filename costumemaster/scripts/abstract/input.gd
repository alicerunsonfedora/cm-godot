# input.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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

# Whether to light up when activated.
export var LIGHT_WHEN_ACTIVE: bool = false

# The color of the light, when activated.
export var ACTIVE_LIGHT_COLOR: Color = Color.white

# The texture scale of the light when activated.
export var ACTIVE_LIGHT_SCALE: float = 1

# The brightness of the light when activated.
export var ACTIVE_LIGHT_ENERGY: float = 1

var _active: bool = false
var _entered = []
var _listening_for_keypress = false
var _permalock = false

onready var _audio: AudioStreamPlayer2D
onready var _hud_data = load("res://interface/hud_timer.tscn") as Resource
onready var _hud_timer: Node2D
onready var _light: Light2D
onready var _timer: Timer

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
	_make_light()
	_make_timer()
	_make_timer_ui()
	_make_audio_player()
	_setup_connections()

# Activate the input device.
# If the duration is a non-zero value, the internal timer will start.
func _activate() -> void:
	if _permalock or _active:
		return
	_active = true
	_on_activate()
	emit_signal("input_active", get_name())
	if LIGHT_WHEN_ACTIVE:
		_light.visible = true
	_audio.play()
	if PERMANENT:
		_permalock = true
	if DURATION > 0:
		_timer.start()
		_hud_timer.visible = true
		_make_audio_tick()
		_audio.play()

# Deactivate the input device.
# If the duration is a non-zero value, the internal timer will stop.
func _deactivate() -> void:
	_active = false
	_on_deactivate()
	emit_signal("input_inactive", get_name())
	_make_audio_turnoff()
	if LIGHT_WHEN_ACTIVE:
		_light.visible = false
	_audio.play()
	if DURATION > 0:
		_timer.stop()
		_hud_timer.visible = false

func _make_light() -> void:
	_light = Light2D.new()
	_light.texture = load("res://assets/fx/lightsource.png")
	_make_light_adjustments()
	_make_light_shadows()
	add_child(_light)

func _make_light_adjustments() -> void:
	_light.z_index += 2
	_light.scale = Vector2(ACTIVE_LIGHT_SCALE, ACTIVE_LIGHT_SCALE)
	_light.color = ACTIVE_LIGHT_COLOR
	_light.mode = Light2D.MODE_ADD
	_light.energy = ACTIVE_LIGHT_ENERGY

func _make_light_shadows() -> void:
	_light.shadow_enabled = true
	_light.shadow_gradient_length = 0.3
	_light.visible = false

func _make_timer() -> void:
	_timer = Timer.new()
	_timer.autostart = false
	_timer.one_shot = true
	_timer.wait_time = DURATION if DURATION > 0 else 1.0
	add_child(_timer)
	var _tim_con = _timer.connect("timeout", self, "_deactivate")
	if _tim_con != OK:
		print_debug(_tim_con)

func _make_timer_ui() -> void:
	_hud_timer = _hud_data.instance()
	_hud_timer.position = Vector2(0, -40)
	_hud_timer.visible = false
	_hud_timer.z_index = 5
	add_child(_hud_timer)

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

func _on_area_entered(area: Area2D) -> void:
	if not area is MovableObject:
		return
	_entered.append(area.name)
	if INTERACTION % 2 == 0:
		_listening_for_keypress = true
	elif not _active and len(_entered) > 0:
		_activate()

func _on_area_exited(area: Area2D) -> void:
	if not area is MovableObject:
		return
	_entered.remove(area.name)
	if INTERACTION % 2 == 0:
		_listening_for_keypress = false
	elif _active and len(_entered) < 1:
		_deactivate()

func _on_body_entered(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"]:
		return
	_entered.append(body.name)
	if INTERACTION % 2 == 0:
		_listening_for_keypress = true
		if body.name == "Clone" or body is MovableObject:
			return
		(body as Player).update_player_hint(1)
	elif not _active and len(_entered) > 0:
		_activate()

func _on_body_exited(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"]:
		return
	_entered.remove(body.name)
	if INTERACTION % 2 == 0:
		_listening_for_keypress = false
		if body.name == "Clone" or body is MovableObject:
			return
		(body as Player).update_player_hint(0)
	elif _active and len(_entered) < 0:
		_deactivate()

# Run post-activation methods and calls. This may be overridden in other classes.
func _on_activate() -> void:
	pass

# Run post-deactivation methods and calls. This may be overridden in other classes.
func _on_deactivate() -> void:
	pass

func _process(_delta) -> void:
	if Input.get_action_strength("interact") and _listening_for_keypress:
		if _active and not _permalock and (_timer.time_left == 0):
			_deactivate()
		else:
			_activate()

func _setup_connections() -> void:
	var _err = connect("body_entered", self, "_on_body_entered")
	_err = connect("body_exited", self, "_on_body_exited")
	_err = connect("area_entered", self, "_on_area_entered")
	_err = connect("area_exited", self, "_on_area_exited")
	if _err != OK:
		push_error(_err)
