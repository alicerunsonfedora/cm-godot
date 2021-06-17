class_name HUD
extends Control

signal costume_request(costume_type)

onready var switch_flash = $Toolbar/FlashCostume as Button
onready var switch_bird = $Toolbar/BirdCostume as Button
onready var switch_magic = $Toolbar/MagiCostume as Button
onready var switch_mega = $Toolbar/MegaCostume as Button
onready var switch_none = $Toolbar/NoneCostume as Button

onready var tut_walk = $PanelMove as Panel
onready var tut_cost = $PanelCostume as Panel
onready var tut_inter = $PanelInteract as Panel
onready var tut_timer = $Timer as Timer

onready var tween = $Tween as Tween

var _costume_rocker = 0

func _ready() -> void:
	_button_connect()
	var _err = tut_timer.connect("timeout", self, "_on_timer_timeout")
	if _err != OK:
		push_error(_err)

func _unhandled_input(event: InputEvent) -> void:
	if event.get_action_strength("costume_change_forward"):
		_cycle_costume(false)
	elif event.get_action_strength("costume_change_backward"):
		_cycle_costume(true)

func _button_connect() -> void:
	var _err = switch_flash.connect("button_up", self, "_send_flash")
	_err = switch_bird.connect("button_up", self, "_send_bird")
	_err = switch_magic.connect("button_up", self, "_send_magic")
	_err = switch_mega.connect("button_up", self, "_send_all")
	_err = switch_none.connect("button_up", self, "_send_none")
	if _err != OK:
		push_error(_err)
		
func _cycle_costume(reverse: bool = false) -> void:
	_costume_rocker = clamp(
		_costume_rocker + (-1 if reverse else 1),
		Player.CostumeType.FLASH_DRIVE as float,
		Player.CostumeType.NONE as float
	) as int
	emit_signal("costume_request", _costume_rocker)

func _disable_all_btn() -> void:
	for child in $Toolbar.get_children():
		child.disabled = true
	$Toolbar.visible = false

func disable_tutorials() -> void:
	disable_tut_walk()
	disable_tut_costume()

func disable_tut_walk() -> void:
	tut_walk.visible = false
	tut_inter.visible = false

func disable_tut_costume() -> void:
	tut_cost.visible = false

func disable_unused(allowed: Array) -> void:
	if len(allowed) < 2:
		_disable_all_btn()
		return
	
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

func _on_timer_timeout() -> void:
	var original = tut_cost.modulate
	tween.interpolate_property(
		tut_cost, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(
		tut_walk, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(
		tut_inter, "modulate", original, Color.transparent, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
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
