extends AbstractOutput

onready var door_texture: TileMap = $InactiveTexture as TileMap
onready var collider: CollisionShape2D = $StaticBody2D/DoorCollider as CollisionShape2D

func _on_activate() -> void:
	._on_activate()
	door_texture.visible = false
	collider.set_deferred("disabled", true)
	
func _on_deactivate() -> void:
	._on_deactivate()
	door_texture.visible = true
	collider.set_deferred("disabled", false)
	
