# mainmenu.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

onready var btn_start = $CanvasLayer/Control/MenuButtons/btn_start as Button
onready var btn_options = $CanvasLayer/Control/MenuButtons/btn_options as Button
onready var btn_quit = $CanvasLayer/Control/MenuButtons/btn_quit as Button
onready var settings: UserDefaults
onready var win_settings = $CanvasLayer/Control/SettingsView as SettingsView

func _ready() -> void:
	settings = UserDefaults.new()
	var _err = btn_start.connect("button_up", self, "_btn_start_press")
	_err = btn_quit.connect("button_up", self, "_btn_quit_press")
	_err = btn_options.connect("button_up", self, "_btn_options_press")
	if _err != OK:
		push_error(_err)
	
	if OS.get_name() in ["HTML5", "iOS", "Android"]:
		btn_quit.disabled = true
		btn_quit.visible = false

func _btn_options_press() -> void:
	win_settings.show()

func _btn_start_press() -> void:
	var _err = get_tree().change_scene("res://scenes/tschmb_01.tscn")
	if _err != OK:
		push_error(_err)

func _btn_quit_press() -> void:
	get_tree().quit()
