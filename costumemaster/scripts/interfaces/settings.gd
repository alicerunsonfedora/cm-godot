# settings.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# The window containing user preferences that can be edited.
class_name SettingsView
extends WindowDialog

onready var chk_allow_music := $VBoxContainer/chk_allow_music as CheckButton
onready var chk_mobile := $VBoxContainer/chk_mobile_controls as CheckButton
onready var chk_persistent_fov := $VBoxContainer/chk_field_of_view as CheckButton
onready var chk_debug_mode := $VBoxContainer/chk_dbg_mode as CheckButton
onready var sel_locale := $VBoxContainer/locale/sel_locale as OptionButton
onready var _settings: UserDefaults

func _ready() -> void:
	_settings = UserDefaults.new()
	chk_allow_music.pressed = _settings.allow_music
	chk_persistent_fov.pressed = _settings.persist_field_of_view
	chk_mobile.pressed = _settings.show_mobile_controls
	chk_debug_mode.pressed = _settings.debug_mode
	
	_load_locales()
	sel_locale.selected = sel_locale.items.find(_settings.preferred_locale)

	if OS.get_name() in ["Android", "iOS"]:
		chk_mobile.disabled = true

	var _err = chk_persistent_fov.connect("toggled", self, "_chk_fov_toggled")
	_err = chk_allow_music.connect("toggled", self, "_chk_music_toggled")
	_err = chk_mobile.connect("toggled", self, "_chk_mobile_toggled")
	_err = chk_debug_mode.connect("toggled", self, "_chk_debug_toggled")
	_err = sel_locale.connect("item_selected", self, "_sel_locale_selected")
	if _err != OK:
		push_error(_err)

func _chk_debug_toggled(value) -> void:
	chk_debug_mode.pressed = value
	_settings.debug_mode = value

func _chk_fov_toggled(value) -> void:
	chk_persistent_fov.pressed = value
	_settings.persist_field_of_view = value

func _chk_mobile_toggled(value) -> void:
	chk_mobile.pressed = value
	_settings.show_mobile_controls = value

func _chk_music_toggled(value) -> void:
	chk_allow_music.pressed = value
	_settings.allow_music = value

func _load_locales() -> void:
	var locales = TranslationServer.get_loaded_locales()
	for locale in locales:
		sel_locale.add_item(locale)
	if len(locales) < 2:
		sel_locale.disabled = true
	

func _sel_locale_selected(idx: int) -> void:
	sel_locale.selected = idx
	_settings.preferred_locale = sel_locale.items[idx]