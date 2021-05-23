class_name ExitDoor
extends AbstractOutput

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
