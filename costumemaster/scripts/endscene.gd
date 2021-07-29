extends Node2D

onready var next_btn := $CanvasLayer/Button
onready var scn_anim := $AnimationTree
onready var scn_timer := $Timer
onready var end_tween := $EndTween
onready var start_tween := $StartTween

func _ready() -> void:
	var _err = next_btn.connect("button_up", self, "_to_main_menu")
	_err = scn_timer.connect("timeout", self, "_timer_ends")
	_err = end_tween.connect("tween_all_completed", self, "_to_main_menu")
	_err = start_tween.connect("tween_all_completed", self, "_start_anim")
	
	start_tween.interpolate_property(
		self, "modulate", modulate, Color.white, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	start_tween.start()
		
	if len(Input.get_connected_joypads()) < 1:
		next_btn.icon = null

func _start_anim() -> void:
	scn_anim.active = true

func _timer_ends() -> void:
	next_btn.visible = false
	end_tween.interpolate_property(
		self, "modulate", Color.white, Color.transparent, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	end_tween.start()

func _to_main_menu() -> void:
	var _err = get_tree().change_scene("res://scenes/main.tscn")
	if _err != OK:
		push_error("Error: %s" % (_err))
