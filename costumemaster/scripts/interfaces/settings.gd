# settings.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# The window containing user preferences that can be edited.
class_name SettingsView
extends WindowDialog

onready var chk_mobile := $TabContainer/PERF_TAB_GENERAL/View/Contents/chk_mobile_controls as CheckButton
onready var chk_persistent_fov := $TabContainer/PERF_TAB_GENERAL/View/Contents/chk_field_of_view as CheckButton
onready var chk_debug_mode := $TabContainer/PERF_TAB_EXTRA/View/Contents/chk_dbg_mode as CheckButton
onready var chk_dbg_end := $TabContainer/PERF_TAB_DEBUG/View/Contents/chk_dbg_end as CheckButton
onready var chk_dbg_flb := $TabContainer/PERF_TAB_DEBUG/View/Contents/chk_dbg_flb as CheckButton
onready var chk_dbg_lvl := $TabContainer/PERF_TAB_DEBUG/View/Contents/chk_dbg_lvl as CheckButton
onready var sel_locale := $TabContainer/PERF_TAB_GENERAL/View/Contents/locale/sel_locale as OptionButton
onready var sld_vol_music := $TabContainer/PERF_TAB_AUDIO/View/Contents/grp_vol_music/sld_vol_music as Slider
onready var sld_vol_sfx := $TabContainer/PERF_TAB_AUDIO/View/Contents/grp_vol_sfx/sld_vol_sfx as Slider
onready var _settings: UserDefaults

func _ready() -> void:
	_settings = UserDefaults.new()
	chk_persistent_fov.pressed = _settings.persist_field_of_view
	chk_mobile.pressed = _settings.show_mobile_controls
	chk_debug_mode.pressed = _settings.debug_mode
	chk_dbg_end.pressed = _settings.animate_end_levels
	chk_dbg_flb.pressed = _settings.fullbright
	chk_dbg_lvl.pressed = _settings.level_name_in_toolbar
	sld_vol_music.value = _settings.volume_db_music
	sld_vol_sfx.value = _settings.volume_db_sfx
	
	_load_locales()
	sel_locale.selected = sel_locale.items.find(_settings.preferred_locale)

	if OS.get_name() in ["Android", "iOS"]:
		chk_mobile.disabled = true

	_connect_ui()
	_disable_debug_pane()

func _chk_debug_toggled(value) -> void:
	chk_debug_mode.pressed = value
	_settings.debug_mode = value
	_disable_debug_pane()

func _chk_dbg_end_toggled(value) -> void:
	chk_dbg_end.pressed = value
	_settings.animate_end_levels = value

func _chk_dbg_flb_toggled(value) -> void:
	chk_dbg_flb.pressed = value
	_settings.fullbright = value

func _chk_dbg_lvl_toggled(value) -> void:
	chk_dbg_lvl.pressed = value
	_settings.level_name_in_toolbar = value

func _chk_fov_toggled(value) -> void:
	chk_persistent_fov.pressed = value
	_settings.persist_field_of_view = value

func _chk_mobile_toggled(value) -> void:
	chk_mobile.pressed = value
	_settings.show_mobile_controls = value

func _connect_ui() -> void:
	var _err = chk_persistent_fov.connect("toggled", self, "_chk_fov_toggled")
	_err = chk_mobile.connect("toggled", self, "_chk_mobile_toggled")
	_err = chk_debug_mode.connect("toggled", self, "_chk_debug_toggled")
	_err = chk_dbg_end.connect("toggled", self, "_chk_dbg_end_toggled")
	_err = chk_dbg_flb.connect("toggled", self, "_chk_dbg_flb_toggled")
	_err = chk_dbg_lvl.connect("toggled", self, "_chk_dbg_lvl_toggled")
	_err = sel_locale.connect("item_selected", self, "_sel_locale_selected")
	_err = sld_vol_music.connect("value_changed", self, "_sld_vol_music_changed")
	_err = sld_vol_sfx.connect("value_changed", self, "_sld_vol_sfx_changed")
	if _err != OK:
		push_error("%s" % _err)

func _disable_debug_pane():
	for child in $TabContainer/PERF_TAB_DEBUG/View/Contents.get_children():
		if child is Label: continue
		child.disabled = not _settings.debug_mode

func _load_locales() -> void:
	var locales = TranslationServer.get_loaded_locales()
	for locale in locales:
		sel_locale.add_item(locale)
	if len(locales) < 2:
		sel_locale.disabled = true
	
func _sel_locale_selected(idx: int) -> void:
	sel_locale.selected = idx
	_settings.preferred_locale = sel_locale.items[idx]

func _sld_vol_music_changed(new_value: float) -> void:
	sld_vol_music.value = new_value
	_settings.volume_db_music = new_value

func _sld_vol_sfx_changed(new_value: float) -> void:
	sld_vol_sfx.value = new_value
	_settings.volume_db_sfx = new_value
