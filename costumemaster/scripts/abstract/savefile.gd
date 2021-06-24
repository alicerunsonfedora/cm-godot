# universe.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# An abstract data class that represents a suspended scene state.
class_name SaveState
extends Node

var current_level: String = ""
var inputs: Dictionary = {}
var movable_objects: Dictionary = {}
var player_position: Vector2 = Vector2.ZERO
var player_costume: int = 0
var save_date: Dictionary = OS.get_datetime()

func save_input_states(input_list: Array) -> void:
	for input in input_list:
		if not input is AbstractInput:
			continue
		var _properties = {}
		_properties["active"] = input.active()
		_properties["time"] = input._timer.time_left
		inputs[input.get_name()] = _properties.duplicate()

func save_movable_objects(objects: Array) -> void:
	for object in objects:
		if not object is MovableObject:
			continue
		movable_objects[object.name] = object.global_position

func _format_save_date() -> String:
	return "%04d-%02d-%02d_%02d:%02d:%02d" % [
		save_date["year"], save_date["month"], save_date["day"], save_date["hour"], 
		save_date["minute"], save_date["second"]
	]

func _to_string() -> String:
	return \
		("SaveState(save_date: '%s', player_position: %s, player_costume: %s, inputs: [%s AbstractInputs], " \
		+ "objects: [%s MovableObjects])") \
		% [_format_save_date(), player_position, player_costume, len(inputs), len(movable_objects)]
