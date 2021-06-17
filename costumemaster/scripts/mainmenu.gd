extends Node2D

onready var btn_start = $CanvasLayer/Control/btn_start as Button
onready var btn_quit = $CanvasLayer/Control/btn_quit as Button

func _ready() -> void:
	var _err = btn_start.connect("button_up", self, "_btn_start_press")
	_err = btn_quit.connect("button_up", self, "_btn_quit_press")
	if _err != OK:
		push_error(_err)

func _btn_start_press() -> void:
	var _err = get_tree().change_scene("res://scenes/tschmb_01.tscn")
	if _err != OK:
		push_error(_err)

func _btn_quit_press() -> void:
	get_tree().quit()
