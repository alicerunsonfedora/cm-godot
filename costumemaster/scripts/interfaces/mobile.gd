# mobile.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name MobileInterface
extends Control

onready var joypad := $Analog
onready var dpad := $DPad

func _ready() -> void:
	joypad.visible = UserDefaults.use_joypad
	dpad.visible = not UserDefaults.use_joypad
