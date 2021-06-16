class_name HUD
extends Control

signal costume_request(costume_type)

onready var switch_flash = $FlashCostume as Button
onready var switch_bird = $BirdCostume as Button
onready var switch_magic = $MagiCostume as Button
onready var switch_mega = $MegaCostume as Button
onready var switch_none = $NoneCostume as Button

func _ready() -> void:
	switch_flash.connect("button_up", self, "_send_flash")
	switch_bird.connect("button_up", self, "_send_bird")
	switch_magic.connect("button_up", self, "_send_magic")
	switch_mega.connect("button_up", self, "_send_all")
	switch_none.connect("button_up", self, "_send_none")

# Hide the debug buttons used for testing.
func hide_debug_menu() -> void:
	switch_flash.visible = false
	switch_bird.visible = false
	switch_magic.visible = false
	switch_mega.visible = false
	switch_none.visible = false

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
