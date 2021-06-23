# defaults.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A class that manages user defaults.
class_name UserDefaults

# Whether to play the soundtrack on top of the sound effects.
# Defaults to True.
var allow_music: bool = true setget _update_allow_music

# Whether to allow the end level animations per level.
# Defaults to true. Only toggleable with debug mode on.
var animate_end_levels: bool = true setget _update_animate_end_levels

# Whether to enable debug mode.
# Defaults to False.
var debug_mode: bool = false setget _update_debug_mode

# The persistent field of view.
# Defaults to zero when no persistent field of view is present.
var field_of_view: float = 0.0 setget _update_field_of_view

# Whether to keep the field of view persistent across levels.
# Defaults to False.
var persist_field_of_view: bool = false setget _update_persist_field_of_view

# Whether to show the mobile UI controls.
# Defaults to the result of OS.has_touchscreen_ui_hint.
var show_mobile_controls: bool = OS.has_touchscreen_ui_hint() setget _update_show_mobile_controls

onready var _config: ConfigFile

func _init() -> void:
	_config = ConfigFile.new()
	var _config_err = _config.load("user://userdefaults.cfg")
	if _config_err != OK:
		push_warning("Failed to load the User Defaults file.")
		_write_new_defaults()
		return
	persist_field_of_view = _config.get_value("defaults", "persist_field_of_view", false)
	field_of_view = _config.get_value("defaults", "field_of_view", 0.0)
	allow_music = _config.get_value("defaults", "allow_music", true)
	show_mobile_controls = _config.get_value("defaults", "show_mobile_controls", OS.has_touchscreen_ui_hint())
	debug_mode = _config.get_value("defaults", "debug_mode", false)
	animate_end_levels = _config.get_value("debug", "animate_end_levels", true)

func _save_defaults() -> void:
	var _err = _config.save("user://userdefaults.cfg")
	if _err != OK:
		push_error(_err)

func _update_allow_music(new_value: bool) -> void:
	allow_music = new_value
	_config.set_value("defaults", "allow_music", new_value)
	_save_defaults()

func _update_animate_end_levels(new_value: bool) -> void:
	animate_end_levels = new_value
	_config.set_value("debug", "animate_end_levels", new_value)
	_save_defaults()

func _update_debug_mode(new_value: bool) -> void:
	debug_mode = new_value
	_config.set_value("defaults", "debug_mode", new_value)
	_save_defaults()

func _update_field_of_view(new_value: float) -> void:
	field_of_view = new_value
	_config.set_value("defaults", "field_of_view", new_value)
	_save_defaults()

func _update_persist_field_of_view(new_value: bool) -> void:
	persist_field_of_view = new_value
	_config.set_value("defaults", "persist_field_of_view", new_value)
	_save_defaults()

func _update_show_mobile_controls(new_value: bool) -> void:
	show_mobile_controls = new_value
	_config.set_value("defaults", "show_mobile_controls", new_value)
	_save_defaults()

func _write_new_defaults() -> void:
	_config.set_value("defaults", "persist_field_of_view", false)
	_config.set_value("defaults", "field_of_view", 0.0)
	_config.set_value("defaults", "allow_music", true)
	_config.set_value("defaults", "show_mobile_controls", OS.has_touchscreen_ui_hint())
	_config.set_value("defaults", "debug_mode", false)
	_config.set_value("debug", "animate_end_levels", true)
	_save_defaults()