# defaults.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A class that manages user defaults.
extends Node

# Debug: Whether to allow the end level animations per level.
# Defaults to true. Only toggleable with debug mode on.
var animate_end_levels: bool = true setget _update_animate_end_levels

# Whether to enable debug mode.
# Defaults to False.
var debug_mode: bool = false setget _update_debug_mode

# The persistent field of view.
# Defaults to zero when no persistent field of view is present.
var field_of_view: float = 0.0 setget _update_field_of_view

# Debug: Whether to show the map using fullbright.
# Defaults to false.
var fullbright: bool = false setget _update_fullbright

# Debug: Whether to display the level's filename in the bottom left.
# Defaults to false.
var level_name_in_toolbar: bool = false setget _update_level_name_in_toolbar

# Whether to keep the field of view persistent across levels.
# Defaults to False.
var persist_field_of_view: bool = false setget _update_persist_field_of_view

# The user's preferred locale for translation purposes.
# Defaults to the operating system's locale.
var preferred_locale: String = OS.get_locale() setget _update_preferred_locale

# Whether to show the mobile UI controls.
# Defaults to the result of OS.has_touchscreen_ui_hint.
var show_mobile_controls: bool = OS.has_touchscreen_ui_hint() setget _update_show_mobile_controls

# The volume DB for music channels.
# Defaults to 0.0.
var volume_db_music: float = 0.0 setget _update_volume_db_music

# The volume DB for sound effects.
# Defaults to 0.0.
var volume_db_sfx: float = 0.0 setget _update_volume_db_sfx

onready var _config: ConfigFile

var _debug = {
	"animate_end_levels": true,
	"fullbright": false,
	"level_name_in_toolbar": false
}

var _defaults = {
	"debug_mode": false,
	"field_of_view": 0.0,
	"persist_field_of_view": true,
	"preferred_locale": OS.get_locale(),
	"show_mobile_controls": OS.has_touchscreen_ui_hint(),
	"volume_db_music": 0.7,
	"volume_db_sfx": 0.7,
}

func _init() -> void:
	_config = ConfigFile.new()
	var _config_err = _config.load("user://userdefaults.cfg")
	if _config_err != OK:
		push_warning("Failed to load the User Defaults file.")
		_write_new_defaults()
		return
	_load_defaults()
	TranslationServer.set_locale(preferred_locale)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(volume_db_music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(volume_db_sfx))


func _load_defaults() -> void:
	animate_end_levels = _config.get_value("debug", "animate_end_levels", true)
	debug_mode = _config.get_value("defaults", "debug_mode", false)
	field_of_view = _config.get_value("defaults", "field_of_view", 0.0)
	fullbright = _config.get_value("debug", "fullbright", false)
	level_name_in_toolbar = _config.get_value("debug", "level_name_in_toolbar", false)
	persist_field_of_view = _config.get_value("defaults", "persist_field_of_view", true)
	preferred_locale = _config.get_value("defaults", "preferred_locale", OS.get_locale())
	show_mobile_controls = _config.get_value("defaults", "show_mobile_controls", OS.has_touchscreen_ui_hint())
	volume_db_music = _config.get_value("defaults", "volume_db_music", 0.0)
	volume_db_sfx = _config.get_value("defaults", "volume_db_sfx", 0.0)

func _save_defaults() -> void:
	var _err = _config.save("user://userdefaults.cfg")
	if _err != OK:
		push_error(_err)

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

func _update_fullbright(new_value: bool) -> void:
	fullbright = new_value
	_config.set_value("debug", "fullbright", new_value)
	_save_defaults()

func _update_level_name_in_toolbar(new_value: bool) -> void:
	level_name_in_toolbar = new_value
	_config.set_value("debug", "level_name_in_toolbar", new_value)
	_save_defaults()

func _update_persist_field_of_view(new_value: bool) -> void:
	persist_field_of_view = new_value
	_config.set_value("defaults", "persist_field_of_view", new_value)
	_save_defaults()

func _update_preferred_locale(new_value: String) -> void:
	if not new_value in TranslationServer.get_loaded_locales():
		push_error("%s is not a valid locale." % new_value)
	TranslationServer.set_locale(new_value)
	preferred_locale = TranslationServer.get_locale()
	_config.set_value("defaults", "preferred_locale", TranslationServer.get_locale())
	_save_defaults()

func _update_show_mobile_controls(new_value: bool) -> void:
	show_mobile_controls = new_value
	_config.set_value("defaults", "show_mobile_controls", new_value)
	_save_defaults()

func _update_volume_db_music(new_value: float) -> void:
	volume_db_music = new_value
	_config.set_value("defaults", "volume_db_music", new_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(new_value))
	_save_defaults()
	
func _update_volume_db_sfx(new_value: float) -> void:
	volume_db_sfx = new_value
	_config.set_value("defaults", "volume_db_sfx", new_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(new_value))
	var _res = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	_save_defaults()

func _write_new_defaults() -> void:
	for key in _defaults.keys():
		_config.set_value("defaults", key, _defaults[key])
	for key in _debug.keys():
		_config.set_value("debug", key, _debug[key])
	_save_defaults()
