# exitdoor.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# An exit door that transitions to another scene.
class_name ExitDoor
extends Door

# The scene to transition to when activated.
export(String, FILE, "*.tscn") var NEXT_SCENE = null

onready var _tween = $Animator as Tween

var _block_animation: bool = false

func _ready() -> void:
	._ready()
	var _tween_err = _tween.connect("tween_all_completed", self, "_switch_scene_context")
	if _tween_err != OK:
		push_error(_tween_err)

func _check_active() -> void:
	._check_active()
	._update_textures_and_colliders()

func _fade_out_scene() -> void:
	var _root = get_tree().root.get_child(0)
	if _root == null:
		push_warning("Root could not be located. Skipping animation.")
		_switch_scene_context()
		return
	_tween.interpolate_property(
		_root, "modulate", _root.modulate, Color8(3, 0, 12, 1), 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.start()

func _on_activate() -> void:
	if _block_animation:
		_switch_scene_context()
	_fade_out_scene()

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

func _switch_scene_context() -> void:
	var _change_err = get_tree().change_scene(NEXT_SCENE)
	if _change_err:
		push_error(_change_err)

func _update_animation(state: bool) -> void:
	_block_animation = not state