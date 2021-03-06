# mainmenu.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

onready var btn_start = $CanvasLayer/Control/MenuButtons/btn_start as Button
onready var btn_resume = $CanvasLayer/Control/MenuButtons/btn_resume as Button
onready var btn_options = $CanvasLayer/Control/MenuButtons/btn_options as Button
onready var btn_quit = $CanvasLayer/Control/MenuButtons/btn_quit as Button
onready var win_settings = $CanvasLayer/Control/SettingsView as SettingsView

func _ready() -> void:
	_btn_connect()
	_btn_hide_quit_for_mobile()
	
	# Autoselect start if a controller is connected. This lets controllers select the
	# main menu.
	if len(Input.get_connected_joypads()) > 0:
		btn_start.grab_focus()
	
	if not SaveUtils.save_exists():
		btn_resume.disabled = true
		
func _btn_connect() -> void:
	var _err = btn_start.connect("button_up", self, "_btn_start_press")
	_err = btn_resume.connect("button_up", self, "_btn_resume_press")
	_err = btn_options.connect("button_up", self, "_btn_options_press")
	_err = btn_quit.connect("button_up", self, "_btn_quit_press")
	if _err != OK:
		push_error(_err)

func _btn_hide_quit_for_mobile() -> void:
	if not OS.get_name() in ["HTML5", "iOS", "Android"]:
		return
	btn_quit.disabled = true
	btn_quit.visible = false

func _btn_options_press() -> void:
	win_settings.show()

func _btn_resume_press() -> void:
	if not SaveUtils.save_exists(): return
	SaveUtils.load_from_file()
	_load_scene()

func _btn_start_press() -> void:
	var _err = get_tree().change_scene("res://scenes/tschmb_01.tscn")
	if _err != OK:
		push_error(_err)

func _btn_quit_press() -> void:
	get_tree().quit()

func _load_scene() -> void:
	var _err = get_tree().change_scene(SaveUtils.state.current_level)
	if _err != OK:
		push_error("%s" % (_err))
