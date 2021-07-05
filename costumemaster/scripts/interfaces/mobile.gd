# mobile.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name MobileInterface
extends Control

onready var joypad := $JoyPad/Sprite/Joystick as TouchScreenButton

const radius := Vector2(64, 64)
const boundary := 64.0

# Returns the normalized vector for the joypad's position. This is used to set the player's position
# when using on-screen controls.
func get_joypad_value() -> Vector2:
		return _get_joypad_position().normalized()

func _get_joypad_position() -> Vector2:
		return joypad.position + radius

func _input(event):
		if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
				joypad.set_global_position(event.position - radius * joypad.global_scale)

				if _get_joypad_position().length() > boundary:
						joypad.set_position(_get_joypad_position().normalized() * boundary - radius)


