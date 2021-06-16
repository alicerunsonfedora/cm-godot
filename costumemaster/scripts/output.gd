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

# A map of all the inputs this output is listening to and whether the input is active.
var _input_map: Dictionary = {}

# Whether the player has interacted with the output after activation.
# When `INTERACT_ON_KEYPRESS` is off, this effectively does nothing.
var _key_lock: bool = false

# Whether the player is in the radius to activate the output and unlock it.
# When `INTERACT_ON_KEYPRESS` is off, this effectively does nothing.
var _can_unlock_key: bool = false

signal output_active()
signal output_inactive()

onready var _cooldown: Timer

# Returns whether the output device is active.
func active() -> bool:
	var _status = false
	if REQUIRE_ALL_INPUTS:
		_status = not false in _input_map.values()
	else:
		_status = true in _input_map.values()

	if INVERT_SIGNAL:
		_status = not _status

	return _status

# Returns the universe accessible to the output, or null if it cannot be found.
func find_universe() -> Universe:
	return get_node("/root/Universe") as Universe

# Returns whether the device is active, the key unlocking mechanism is on, and the cooldown is not
# in effect.
func _active_and_unlocked() -> bool:
	if not INTERACT_ON_KEYPRESS:
		return active() and _cooldown.time_left == 0
	return active() and _key_lock and _cooldown.time_left == 0

func _ready() -> void:
	var _ent_err = connect("body_entered", self, "_on_body_entered")
	var _exi_err = connect("body_exited", self, "_on_body_exited")

	_cooldown = Timer.new()
	_cooldown.autostart = false
	_cooldown.one_shot = true
	_cooldown.wait_time = 5.0
	add_child(_cooldown)

	if _ent_err != OK:
		print_debug(_ent_err)
	if _exi_err != OK:
		print_debug(_exi_err)

	if len(INPUTS) == 0:
		push_warning("Input list is empty.")

	for input_path in INPUTS:
		var node = get_node(input_path)
		if not node or not node is AbstractInput:
			continue

		var input = node as AbstractInput
		if input.get_name() in _input_map.keys():
			continue

		_input_map[input.get_name()] = input.active()
		var _inp_act_err = input.connect("input_active", self, "_on_input_active")
		var _inp_dea_err = input.connect("input_inactive", self, "_on_input_deactive")

		if _inp_act_err != OK:
			print_debug(_inp_act_err)
		if _inp_dea_err != OK:
			print_debug(_inp_dea_err)

func _process(_delta) -> void:
	if INTERACT_ON_KEYPRESS and Input.get_action_strength("interact") and _can_unlock_key:
		_key_lock = active()
		_check_active()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player" and body.name != "PlayerNode":
		return
	if INTERACT_ON_KEYPRESS and active():
		_can_unlock_key = true

func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player" and body.name != "PlayerNode":
		return
	if INTERACT_ON_KEYPRESS:
		_can_unlock_key = false

func _check_active():
	if _active_and_unlocked():
		_cooldown.start()
		_on_activate()
		emit_signal("output_active")

func _check_inactive():
	if not _active_and_unlocked():
		_on_deactivate()
		emit_signal("output_inactive")

func _on_input_active(name) -> void:
	_input_map[name] = true
	_check_active()

func _on_input_deactive(name) -> void:
	_input_map[name] = false
	_check_inactive()

# Run post-activation methods and calls. This may be overridden in other classes.
func _on_activate() -> void:
	pass

# Run post-deactivation methods and calls. This may be overridden in other classes.
func _on_deactivate() -> void:
	pass
