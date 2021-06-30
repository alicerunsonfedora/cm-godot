# obj_door.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A door that blocks access unless activated.
class_name Door
extends AbstractOutput

onready var _door_texture := $InactiveTexture as TileMap
onready var _collider := $StaticBody2D/DoorCollider as CollisionShape2D
onready var _tweenie := $Fader as Tween

func _fade_body_through_door(body: Node2D, to_value: float = 1) -> void:
	var _animate = _tweenie.interpolate_property(
		body, "modulate", body.modulate, Color(1, 1, 1, to_value), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animate = _tweenie.start()

func _on_activate() -> void:
	._on_activate()
	_door_texture.visible = false
	_collider.set_deferred("disabled", true)

func _on_body_entered(body: Node2D) -> void:
	._on_body_entered(body)
	if not body is Player: return
	_fade_body_through_door(body, 0.1)

func _on_body_exited(body: Node2D) -> void:
	._on_body_exited(body)
	if not body is Player: return
	_fade_body_through_door(body)
	
func _on_deactivate() -> void:
	._on_deactivate()
	_door_texture.visible = true
	_collider.set_deferred("disabled", false)

func _update_textures() -> void:
	_door_texture.visible = not active()
	
func _update_textures_and_colliders() -> void:
	_door_texture.visible = not active()
	_collider.set_deferred("disabled", active())
