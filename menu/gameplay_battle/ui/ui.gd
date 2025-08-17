extends Control

signal on_activate_ability
signal end_turn

onready var unit_control = $SafeArea/VBoxContainer/unit_control
onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var floating = $floating

var floating_infos :Dictionary = {} # {unit :floating info}

func show_unit_detail(v :bool, unit :BaseUnit = null, data :UnitData = null):
	unit_control.show_unit_detail(v, unit, data)
	
func add_unit_floating_info(unit :BaseUnit):
	if unit.player_id == Global.current_player_id:
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
		info.visible = unit.visible
		var v2 = camera.unproject_position(pos)
		info.rect_position = v2 - info.rect_pivot_offset
		
func _on_exit_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")

func _on_unit_control_end_turn():
	emit_signal("end_turn")
	
func _on_unit_control_on_activate_ability():
	emit_signal("on_activate_ability")
	
