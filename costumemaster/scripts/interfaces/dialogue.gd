# dialogue.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# UI scene that shows a piece of dialogue from a character.
class_name Dialogue
extends Popup

export var DIALOGUE_SET: String = "tschmb_00"

var _dialogue: Array = []

onready var next_button = $VBoxContainer/HBoxContainer/NextButton as Button
onready var lbl_dialogue = $VBoxContainer/DialogueChannel as Label

func _ready():
	visible = false
	if not _dialogue.empty():
		_pop_dialogue()
	next_button.connect("pressed", self, "_on_button_press")

func load_json_values() -> void:
	var json_file = File.new()
	if not json_file.file_exists("res://dialogue.json"):
		push_error("Filepath specified does not exist.")
		return

	json_file.open("res://dialogue.json", File.READ)
	var json_data = JSON.parse(json_file.get_as_text())
	json_file.close()

	if typeof(json_data.result) != TYPE_DICTIONARY:
		push_error("Unexpected JSON format.")

	_dialogue = json_data.result[DIALOGUE_SET]

func _pop_dialogue() -> void:
	var new = _dialogue.pop_front()
	if not new:
		visible = false
		return
	lbl_dialogue.text = tr(new)

func _on_button_press():
	_pop_dialogue()
