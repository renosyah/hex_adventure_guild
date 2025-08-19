extends Control

signal on_activate_ability
signal end_turn

const vanguard_ability = preload("res://assets/icons/spear_defence.png")

onready var unit_detail = $HBoxContainer2/CenterContainer2/unit_info_panel/unit_detail
onready var ability_holder = $HBoxContainer2/MarginContainer/ability_holder
onready var unit_info_panel = $HBoxContainer2/CenterContainer2/unit_info_panel
onready var ability_button = $HBoxContainer2/MarginContainer/ability_holder/ability

func _ready():
	ability_holder.visible = false
	unit_info_panel.visible = false

func show_unit_detail(v :bool, unit :BaseUnit = null, data :UnitData = null):
	unit_info_panel.visible = v
	ability_holder.visible = v
	
	if is_instance_valid(unit) and data:
		if unit.player_id == Global.current_player_id:
			ability_button.disabled = not unit.has_action()
			
			if unit is Vanguard:
				ability_button.icon = vanguard_ability
				
			else:
				ability_button.disabled = true
				ability_button.icon = null
			
		unit_detail.show_unit_detail(unit, data)
		
func _on_end_turn_pressed():
	unit_info_panel.visible = false
	ability_holder.visible = false
	emit_signal("end_turn")

func _on_ability_pressed():
	unit_info_panel.visible = false
	ability_holder.visible = false
	emit_signal("on_activate_ability")
