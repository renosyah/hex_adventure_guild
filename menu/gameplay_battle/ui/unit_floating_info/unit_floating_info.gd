extends Control

onready var label = $HBoxContainer/Label

func set_hp(v :int):
	label.text = "%s" % v

func unit_take_damage(_unit, _dmg, from):
	label.text = "%s" % _unit.hp

func unit_dead(_unit, _tile):
	queue_free()
