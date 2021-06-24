# savefile.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# An abstract data class that represents a suspended scene state.
class_name SaveState
extends Node

# The current level the save data pertains to.
# This filepath can be used to load the scene right away.
var current_level: String = ""

# A dictionary of the various inputs in the level, with a sub-dictionary of whether they are active and the duration, if
# timed.
var inputs: Dictionary = {}

# A dictionary of the movable objects in the levels and their position.
var movable_objects: Dictionary = {}

# The player's position in the level.
var player_position: Vector2 = Vector2.ZERO

# The player's current costume.
var player_costume: int = 0

# The date and time the save was created.
var save_date: Dictionary = OS.get_datetime()

# Load the save data from a JSON dictionary.
func load_from_serialized_data(data: Dictionary) -> void:
	save_date = data["save_date"]
	current_level = data["current_level"]
	player_position = Vector2(data["player_position"]["x"], data["player_position"]["y"])
	player_costume = data["player_costume"]
	inputs = data["inputs"]
	movable_objects = {}
	for object in data["movable_objects"].keys():
		movable_objects[object] = Vector2(data["movable_objects"][object]["x"], data["movable_objects"][object]["y"])

# Save the input states in a format readable by the save.
# Parameters:
# 	input_list: An array of AbstractInput nodes that the save system will parse for information.
func save_input_states(input_list: Array) -> void:
	for input in input_list:
		if not input is AbstractInput:
			continue
		var _properties = {}
		_properties["active"] = input.active()
		_properties["time"] = input._timer.time_left
		inputs[input.get_name()] = _properties.duplicate()

# Save the movable objects in a format readable by the save.
# Parameters:
# 	objects: An array of MovableObject nodes that the save system will parse for information.
func save_movable_objects(objects: Array) -> void:
	for object in objects:
		if not object is MovableObject:
			continue
		movable_objects[object.name] = object.global_position

# Serialize the current save object into a dictionary.
# Returns: A JSON-compatible dictionary containing the save data.
func serialize() -> Dictionary:
	var _movable = {}
	for object in movable_objects.keys():
		_movable[object] = {
			"x": movable_objects[object].x,
			"y": movable_objects[object].y
		}
	return {
		"save_date": save_date,
		"current_level": current_level,
		"player_costume": player_costume,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		},
		"inputs": inputs.duplicate(),
		"movable_objects": _movable.duplicate()
	}

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
