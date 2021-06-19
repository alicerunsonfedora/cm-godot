# obj_door.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# A door that blocks access unless activated.
class_name Door
extends AbstractOutput

onready var _door_texture: TileMap = $InactiveTexture as TileMap
onready var _collider: CollisionShape2D = $StaticBody2D/DoorCollider as CollisionShape2D

func _on_activate() -> void:
	._on_activate()
	_door_texture.visible = false
	_collider.set_deferred("disabled", true)
	
func _on_deactivate() -> void:
	._on_deactivate()
	_door_texture.visible = true
	_collider.set_deferred("disabled", false)
	
