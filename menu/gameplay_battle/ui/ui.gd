extends Control

signal on_activate_ability
signal end_turn

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var unit_detail = $SafeArea/VBoxContainer/HBoxContainer2/CenterContainer2/CenterContainer/unit_detail
onready var unit_info = $SafeArea/VBoxContainer/HBoxContainer2/CenterContainer2/CenterContainer
onready var ability = $SafeArea/VBoxContainer/HBoxContainer2/ability

func _ready():
	unit_info.visible = false
	ability.visible = false
	
func _on_end_turn_pressed():
	emit_signal("end_turn")
	
func show_unit_detail(v :bool, data :UnitData = null):
	unit_info.visible = v
	ability.visible = v
	
	if data:
		unit_detail.show_unit_detail(data)

func _on_exit_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")

func _on_ability_pressed():
	emit_signal("on_activate_ability")
