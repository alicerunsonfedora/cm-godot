extends Node2D

onready var btn_start = $CanvasLayer/Control/btn_start as Button
onready var btn_quit = $CanvasLayer/Control/btn_quit as Button
onready var chk_fov = $CanvasLayer/Control/FOVPersist as CheckButton

onready var settings: UserDefaults

func _ready() -> void:
	settings = UserDefaults.new()
	chk_fov.pressed = settings.persist_field_of_view
	var _err = btn_start.connect("button_up", self, "_btn_start_press")
	_err = btn_quit.connect("button_up", self, "_btn_quit_press")
	_err = chk_fov.connect("toggled", self, "_chk_fov_toggled")
	if _err != OK:
		push_error(_err)

func _btn_start_press() -> void:
	var _err = get_tree().change_scene("res://scenes/tschmb_01.tscn")
	if _err != OK:
		push_error(_err)

func _btn_quit_press() -> void:
	get_tree().quit()

func _chk_fov_toggled(value) -> void:
	chk_fov.pressed = value
	settings.persist_field_of_view = value
