# exitdoor.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# An exit door that transitions to another scene.
class_name ExitDoor
extends AbstractOutput

# The scene to transition to when activated.
export(String, FILE, "*.tscn") var NEXT_SCENE = null

func _on_activate() -> void:
	var _change_err = get_tree().change_scene(NEXT_SCENE)
	if _change_err:
		push_error(_change_err)

func _on_body_entered(body: Node2D) -> void:
	._on_body_entered(body)
	if body.name != "Player" and body.name != "PlayerNode":
		return
	var player = body as Player
	player.update_player_hint(2 if active() else 3)

func _on_body_exited(body: Node2D) -> void:
	._on_body_exited(body)
	if body.name != "Player" and body.name != "PlayerNode":
		return
	var player = body as Player
	player.update_player_hint(0)
