# movable.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A class that represents a movable object, which may interact with input and output devices.
class_name MovableObject
extends Area2D

onready var _player: Player

var _listening_for_keypress = false
var _old_z_index = 0

func _ready() -> void:
	var _err = connect("body_entered", self, "_on_body_entered")
	_err = connect("body_exited", self, "_on_body_exited")
	if _err != OK:
		push_error(_err)

func _connect_to_player(player: Player) -> void:
	_player = player
	var _err = _player.connect("wants_pickup", self, "_pickup")
	_err = _player.connect("wants_drop", self, "_drop")
	if _err != OK:
		push_error(_err)

func _drop() -> void:
	if _player.CURRENT_COSTUME != Player.CostumeType.MAGIC:
		_player._play_cant_use_sound()
		return
	_player._has_item = false
	_player.remove_child(self)
	_player.get_parent().add_child(self)
	_player.update_player_hint(Player.PlayerHint.NONE)
	_set_dropped()

func _on_body_entered(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"] or _player._has_item:
		return
	_listening_for_keypress = true
	if _player.CURRENT_COSTUME == Player.CostumeType.MAGIC:
		_player.update_player_hint(Player.PlayerHint.INTERACT)

func _on_body_exited(body: Node2D) -> void:
	if not body.name in ["Player", "PlayerNode", "Clone"] or _player._has_item:
		return
	_listening_for_keypress = false
	_player.update_player_hint(Player.PlayerHint.NONE)

func _pickup() -> void:
	if not _listening_for_keypress or _player.CURRENT_COSTUME != Player.CostumeType.MAGIC:
		_player._play_cant_use_sound()
		return
	get_parent().remove_child(self)
	_player.add_child(self)
	_player.update_player_hint(Player.PlayerHint.HOLDING_ITEM)
	_player._has_item = true
	_set_pickup()
	
func _set_dropped() -> void:
	position = _player.position
	scale = Vector2.ONE
	modulate = Color.white
	monitorable = true
	z_index = _old_z_index

func _set_pickup() -> void:
	_old_z_index = z_index
	scale = Vector2(0.3, 0.3)
	modulate = Color.cornflower
	position = Vector2(0, 20)
	monitorable = false
	z_index = 0
