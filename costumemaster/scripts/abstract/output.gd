# output.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A class that listens for input devices and activates/deactivates accordingly.
class_name AbstractOutput
extends Area2D

# A list of node paths that connect to this output device.
export(Array, NodePath) var INPUTS = []

# Whether all inputs must be active for the output to be active.
# Turning this on will indicate that the operation to use when checking for an active state
# is `AND`, and `OR` when this is turned off.
export(bool) var REQUIRE_ALL_INPUTS = false

# Whether the active signal should be inverted.
# Turning this on will indicate that the operation to use when checking for an active state
# is either `NAND` or `NOR`.
export(bool) var INVERT_SIGNAL = false

# Whether the player needs to interact with the output to unlock.
# Turning this on will indicate that the output must be active in addition to the keypress
# as an additional operation.
export(bool) var INTERACT_ON_KEYPRESS = false

var _can_unlock_key: bool = false
var _input_map: Dictionary = {}
var _key_lock: bool = false

signal output_active()
signal output_inactive()

onready var _cooldown: Timer

func _ready() -> void:
	_setup_collision_listeners()
	_setup_cooldown()
	_setup_input_list()

# Returns whether the output device is active.
func active() -> bool:
	var _status = false
	if REQUIRE_ALL_INPUTS:
		_status = _input_map.empty() or not false in _input_map.values()
	else:
		_status = true in _input_map.values() or _input_map.empty()
	if INVERT_SIGNAL:
		_status = not _status
	return _status

# Returns whether the device is active, the key unlocking mechanism is on, and the cooldown is not
# in effect.
func _active_and_unlocked() -> bool:
	if not INTERACT_ON_KEYPRESS:
		return active() and _cooldown.time_left == 0
	return active() and _key_lock and _cooldown.time_left == 0

func _check_active():
	if not _active_and_unlocked():
		return
	_cooldown.start()
	_on_activate()
	emit_signal("output_active")

func _check_inactive():
	if _active_and_unlocked():
		return
	_on_deactivate()
	emit_signal("output_inactive")

func _link_input(input_path: NodePath) -> void:
	var node = get_node(input_path)
	if not node or not node is AbstractInput:
		return
	var input = node as AbstractInput
	if input.get_name() in _input_map.keys():
		return
	_input_map[input.get_name()] = input.active()
	var _err = input.connect("input_active", self, "_on_input_active")
	_err = input.connect("input_inactive", self, "_on_input_deactive")
	if _err != OK:
		push_error(_err)

func _on_body_entered(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"]:
		return
	if INTERACT_ON_KEYPRESS and active():
		_can_unlock_key = true

func _on_body_exited(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"]:
		return
	if INTERACT_ON_KEYPRESS:
		_can_unlock_key = false

# Run post-activation methods and calls. This may be overridden in other classes.
func _on_activate() -> void:
	pass

# Run post-deactivation methods and calls. This may be overridden in other classes.
func _on_deactivate() -> void:
	pass

func _on_input_active(name) -> void:
	_input_map[name] = true
	_check_active()

func _on_input_deactive(name) -> void:
	_input_map[name] = false
	_check_inactive()

func _process(_delta) -> void:
	if INTERACT_ON_KEYPRESS and Input.get_action_strength("interact") and _can_unlock_key:
		_key_lock = active()
		_check_active()

func _setup_collision_listeners() -> void:
	var _ent_err = connect("body_entered", self, "_on_body_entered")
	var _exi_err = connect("body_exited", self, "_on_body_exited")
	if _ent_err != OK:
		print_debug(_ent_err)
	if _exi_err != OK:
		print_debug(_exi_err)

func _setup_cooldown() -> void:
	_cooldown = Timer.new()
	_cooldown.autostart = false
	_cooldown.one_shot = true
	_cooldown.wait_time = 5.0
	add_child(_cooldown)

func _setup_input_list() -> void:
	if len(INPUTS) == 0:
		push_warning("Input list is empty.")
	for input_path in INPUTS:
		_link_input(input_path)