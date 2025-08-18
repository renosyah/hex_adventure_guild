extends MarginContainer

onready var label = $MarginContainer/HBoxContainer/VBoxContainer/Label
onready var icon = $MarginContainer/HBoxContainer/VBoxContainer/potrait/icon

func show_unit_detail(unit :BaseUnit, data :UnitData):
	label.text = "%s" % data.unit_name
	icon.texture = PotraitGenerator.get_soldier_potrait(data.unit_potrait[0],data.unit_potrait[1])
