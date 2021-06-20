# mainmenu.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

onready var btn_start = $CanvasLayer/Control/MenuButtons/btn_start as Button
onready var btn_quit = $CanvasLayer/Control/MenuButtons/btn_quit as Button
onready var chk_fov = $CanvasLayer/Control/Sliders/FOVPersist as CheckButton
onready var chk_music = $CanvasLayer/Control/Sliders/Music as CheckButton

onready var settings: UserDefaults

func _ready() -> void:
	settings = UserDefaults.new()
	chk_fov.pressed = settings.persist_field_of_view
	chk_music.pressed = settings.allow_music
	var _err = btn_start.connect("button_up", self, "_btn_start_press")
	_err = btn_quit.connect("button_up", self, "_btn_quit_press")
	_err = chk_fov.connect("toggled", self, "_chk_fov_toggled")
	_err = chk_music.connect("toggled", self, "_chk_music_toggled")
	if _err != OK:
		push_error(_err)

func _btn_start_press() -> void:
	var _err = get_tree().change_scene("res://scenes/tschmb_01.tscn")
	if _err != OK:
		push_error(_err)

func _btn_quit_press() -> void:
	get_tree().quit()

func _chk_fov_toggled(value) -> void:
	chk_fov.pressed = value
	settings.persist_field_of_view = value

func _chk_music_toggled(value) -> void:
	chk_music.pressed = value
	settings.allow_music = value
