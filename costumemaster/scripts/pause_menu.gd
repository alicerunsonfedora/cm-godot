# pause_menu.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

onready var btn_resume = $VBoxContainer/Resume as Button
onready var btn_options = $VBoxContainer/Options as Button
onready var btn_main = $VBoxContainer/Button as Button
onready var win_opts = $SettingsView as SettingsView

func _ready() -> void:
	var _err = btn_resume.connect("button_up", self, "_btn_resume_press")
	_err = btn_options.connect("button_up", self, "_btn_options_press")
	_err = btn_main.connect("button_up", self, "_btn_main_press")
	if _err != OK:
		push_error(_err)

func _btn_main_press() -> void:
	get_tree().paused = false
	var _err = get_tree().change_scene("res://scenes/main.tscn")
	if _err != OK:
		push_error(_err)

func _btn_options_press() -> void:
	win_opts.show()

func _btn_resume_press() -> void:
	visible = false
	get_tree().paused = false
