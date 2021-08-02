# save_utils.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A helper class designed to faciliate saving and loading states.
extends Node

# The current save state.
var state = SaveState.new()

# Load the save state from the save file.
func load_from_file() -> void:
	var file = File.new()
	var _file_err = file.open_encrypted_with_pass("user://current.save", File.READ, OS.get_unique_id())
	if _file_err != OK:
		push_error("Failed to open save file for loading. %s" % _file_err)
		return
	var _state = file.get_as_text()
	state.load_from_serialized_data(parse_json(_state))
	file.close()

# Returns whether the current save file exists.
func save_exists() -> bool:
	var file = File.new()
	return file.file_exists("user://current.save")

# Save the current state in memory to the save file.
# Note: To preserve save integrity, the save file is encrypted.
func save_to_file() -> void:
	var file = File.new()
	var _file_err = file.open_encrypted_with_pass("user://current.save", File.WRITE, OS.get_unique_id())
	if _file_err != OK:
		push_error("Failed to open save file for writing. %s" % _file_err)
		return
	file.store_string(to_json(state.serialize()))
	file.close()
