# dialogue_trigger.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name DialogueTrigger
extends AbstractOutput

export var LOAD_DIALOGUE_SET: String = "tschmb_01"

onready var _dialogue: Dialogue
onready var _dialogue_data := load("res://interface/dialogue.tscn")

func _on_activate() -> void:
	._on_activate()
	_dialogue = _dialogue_data.instance()
	_dialogue.DIALOGUE_SET = LOAD_DIALOGUE_SET
	_dialogue.load_json_values()
	get_parent().add_child(_dialogue)
	_dialogue.popup_centered()