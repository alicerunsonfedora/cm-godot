# hud.gd
# (C) 2021 Marquis Kurt.
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name HUD
extends Control

signal costume_request(costume_type)
signal restart_level_request()
signal update_field_of_view_request(fov)

onready var btn_restart = $Toolbar/Restart as Button
onready var mobile_ui = $MobileUI as Control
onready var slider_fov = $AuxToolbar/FOVSlider as Slider
onready var switch_flash = $Toolbar/FlashCostume as Button
onready var switch_bird = $Toolbar/BirdCostume as Button
onready var switch_magic = $Toolbar/MagiCostume as Button
onready var switch_mega = $Toolbar/MegaCostume as Button
onready var switch_none = $Toolbar/NoneCostume as Button
onready var tut_walk = $PanelMove as Panel
onready var tut_cost = $PanelCostume as Panel
onready var tut_inter = $PanelInteract as Panel
onready var tut_restart = $PanelRestart as Panel
onready var tut_camera = $PanelCamera as Panel
onready var tut_timer = $Timer as Timer
onready var tween = $Tween as Tween

var _available_costumes := []
var _costume_rocker = Player.CostumeType.DEFAULT as float


func _ready() -> void:
	_button_connect()
	var _err = tut_timer.connect("timeout", self, "_on_timer_timeout")
	if _err != OK:
		push_error(_err)

# Disable the mobile UI.
func disable_mobile_ui() -> void:
	mobile_ui.visible = false

# Disable all tutorials on the HUD.
func disable_tutorials() -> void:
	disable_tut_walk()
	disable_tut_costume()
	disable_restart()

# Disable the tutorial that displays the costume switching UI.
func disable_tut_costume() -> void:
	tut_cost.visible = false

# Disable the tutorial that displayes the restart UI.
func disable_tut_restart() -> void:
	tut_restart.visible = false

# Disable the tutorials for basic movement and interaction.
func disable_tut_walk() -> void:
	tut_walk.visible = false
	tut_inter.visible = false
	tut_camera.visible = false

# Disable the restart button.
func disable_restart() -> void:
	btn_restart.disabled = true
	btn_restart.visible = false

# Disable buttons that will not be in use for the level.
# Parameters:
# 	allowed: An array of costumes to allow; i.e., remain enabled.
func disable_unused(allowed: Array) -> void:
	if len(allowed) < 2:
		_disable_all_btn()
		return
	
	_available_costumes = allowed.duplicate()
	_costume_rocker = _available_costumes.pop_front()
	if not Player.CostumeType.FLASH_DRIVE in allowed:
		switch_flash.disabled = true
	if not Player.CostumeType.SWIFT_BIRD in allowed:
		switch_bird.disabled = true
	if not Player.CostumeType.MAGIC in allowed:
		switch_magic.disabled = true
	if not Player.CostumeType.ALL in allowed:
		switch_mega.disabled = true
		switch_mega.visible = false
	if not Player.CostumeType.DEFAULT in allowed:
		switch_none.disabled = true
		switch_none.visible = false

# Set tbe bounds for the field of view slider on the HUD.
# Parameters:
# 	min_value: The absolute minimum field of view for the level.
func set_fov_bounds(min_value: float) -> void:
	slider_fov.min_value = -1 - min_value
	slider_fov.max_value = -1 * min_value
	slider_fov.value = min_value

func _button_connect() -> void:
	var _err = switch_flash.connect("button_up", self, "_send_flash")
	_err = switch_bird.connect("button_up", self, "_send_bird")
	_err = switch_magic.connect("button_up", self, "_send_magic")
	_err = switch_mega.connect("button_up", self, "_send_all")
	_err = switch_none.connect("button_up", self, "_send_none")
	_err = btn_restart.connect("button_up", self, "_send_restart")
	_err = slider_fov.connect("value_changed", self, "_send_fov")
	if _err != OK:
		push_error(_err)
		
func _cycle_costume(reverse: bool = false) -> void:
	if reverse:
		_available_costumes.push_front(_costume_rocker)
		_costume_rocker = _available_costumes.pop_back()
	else:
		_available_costumes.push_back(_costume_rocker)
		_costume_rocker = _available_costumes.pop_front()
	emit_signal("costume_request", _costume_rocker as int)

func _disable_all_btn() -> void:
	for child in $Toolbar.get_children():
		if not child is Button or child.name == "Restart": continue
		child.disabled = true
		child.visible = false

func _on_timer_timeout() -> void:
	var original = tut_cost.modulate
	tween.interpolate_property(
		tut_walk, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(
		tut_camera, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(
		tut_cost, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(
		tut_inter, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(
		tut_restart, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _send_flash() -> void:
	emit_signal("costume_request", Player.CostumeType.FLASH_DRIVE)

func _send_bird() -> void:
	emit_signal("costume_request", Player.CostumeType.SWIFT_BIRD)

func _send_magic() -> void:
	emit_signal("costume_request", Player.CostumeType.MAGIC)

func _send_none() -> void:
	emit_signal("costume_request", Player.CostumeType.DEFAULT)

func _send_all() -> void:
	emit_signal("costume_request", Player.CostumeType.ALL)

func _send_restart() -> void:
	emit_signal("restart_level_request")

func _send_fov(value: float) -> void:
	emit_signal("update_field_of_view_request", abs(value))

func _unhandled_input(event: InputEvent) -> void:
	if event.get_action_strength("costume_change_forward"):
		_cycle_costume(false)
	elif event.get_action_strength("costume_change_backward"):
		_cycle_costume(true)
	elif event.get_action_strength("zoom_in"):
		slider_fov.value += 0.1
	elif event.get_action_strength("zoom_out"):
		slider_fov.value -= 0.1
