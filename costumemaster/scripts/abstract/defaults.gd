# defaults.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name UserDefaults

# The persistent field of view.
# Defaults to zero when no persistent field of view is present.
var field_of_view = 0.0 setget _update_field_of_view

# Whether to keep the field of view persistent across levels.
# Defaults to False.
var persist_field_of_view = false setget _update_persist_field_of_view

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

func _save_defaults() -> void:
	var _err = _config.save("user://userdefaults.cfg")
	if _err != OK:
		push_error(_err)

func _update_persist_field_of_view(new_value: bool) -> void:
	persist_field_of_view = new_value
	_config.set_value("defaults", "persist_field_of_view", new_value)
	_save_defaults()

func _update_field_of_view(new_value: float) -> void:
	field_of_view = new_value
	_config.set_value("defaults", "field_of_view", new_value)
	_save_defaults()

func _write_new_defaults() -> void:
	_config.set_value("defaults", "persist_field_of_view", false)
	_config.set_value("defaults", "field_of_view", 0.0)
	_save_defaults()