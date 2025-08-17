extends Control

signal on_activate_ability
signal end_turn

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var unit_detail = $SafeArea/VBoxContainer/HBoxContainer2/CenterContainer2/CenterContainer/unit_detail
onready var unit_info = $SafeArea/VBoxContainer/HBoxContainer2/CenterContainer2/CenterContainer
onready var ability = $SafeArea/VBoxContainer/HBoxContainer2/MarginContainer/ability
onready var floating = $floating

var floating_infos :Dictionary = {} # {unit :floating info}

func _ready():
	unit_info.visible = false
	ability.visible = false
	
func _on_end_turn_pressed():
	emit_signal("end_turn")
	
func add_unit_floating_info(unit :BaseUnit):
	var info = preload("res://menu/gameplay_battle/ui/unit_floating_info/unit_floating_info.tscn").instance()
	floating.add_child(info)
	unit.connect("unit_take_damage", info, "unit_take_damage")
	unit.connect("unit_dead", info, "unit_dead")
	info.set_hp(unit.hp)
	floating_infos[unit] = info
	
func update_cam_position(camera :Camera):
	for key in floating_infos.keys():
		var unit :BaseUnit = key
		if unit.is_dead():
			floating_infos.erase(unit)
			return
			
		var pos = unit.global_position + (Vector3.UP * 1.5) + Vector3.FORWARD * 0.8
		if camera.is_position_behind(pos):
			continue
			
		var info = (floating_infos[key] as Control)
		var v2 = camera.unproject_position(pos)
		info.rect_position = v2 - info.rect_pivot_offset
		
func show_unit_detail(v :bool, unit :BaseUnit = null, data :UnitData = null):
	unit_info.visible = v
	ability.visible = false
	
	if unit and data:
		if unit is Vanguard and unit.has_action():
			ability.visible = v
			
		unit_detail.show_unit_detail(unit, data)

func _on_exit_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")

func _on_ability_pressed():
	emit_signal("on_activate_ability")
