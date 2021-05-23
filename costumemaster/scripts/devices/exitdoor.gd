class_name ExitDoor
extends AbstractOutput

export(String, FILE, "*.tscn") var NEXT_SCENE = null

func _on_activate() -> void:
	var _change_err = get_tree().change_scene(NEXT_SCENE)
	if _change_err:
		push_error(_change_err)
