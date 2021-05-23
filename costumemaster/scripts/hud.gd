class_name HUD
extends Control

signal costume_request(costume_type)

onready var switch_flash = $FlashCostume as Button
onready var switch_bird = $BirdCostume as Button

func _ready() -> void:
	switch_flash.connect("button_up", self, "_send_flash")
	switch_bird.connect("button_up", self, "_send_bird")
	pass

func _send_flash() -> void:
	emit_signal("costume_request", Player.CostumeType.FLASH_DRIVE)
	
func _send_bird() -> void:
	emit_signal("costume_request", Player.CostumeType.SWIFT_BIRD)
