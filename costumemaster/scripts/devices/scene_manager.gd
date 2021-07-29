class_name SceneManagerOutput
extends AbstractOutput

export(String, FILE, "*.tscn") var DESTINATION_SCENE = null

func _on_activate() -> void:
	._on_activate()
	var _err = get_tree().change_scene(DESTINATION_SCENE)
	if _err != OK:
		push_error("%s" % (_err))

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
