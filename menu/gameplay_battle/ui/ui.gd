extends Control

signal on_activate_ability
signal end_turn

onready var game_ui = $SafeArea/VBoxContainer
onready var unit_control = $SafeArea/VBoxContainer/unit_control
onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var floating = $floating
onready var loading_turn = $loading
onready var battle_result = $SafeArea/battle_result
onready var battle_result_text = $SafeArea/battle_result/MarginContainer/VBoxContainer/battle_result_text

var floating_infos :Dictionary = {} # {unit :floating info}

func _ready():
	loading_turn.visible = false
	battle_result.visible = false

func show_unit_detail(v :bool, unit :BaseUnit = null, data :UnitData = null):
	unit_control.show_unit_detail(v, unit, data)
	
func add_unit_floating_info(unit :BaseUnit):
	var is_for = 1
	
	var is_player_unit = unit.player_id == Global.current_player_id
	var is_team = not is_player_unit and unit.team == Global.current_player_team
	
	if is_player_unit:
		is_for = 1
		
	elif is_team:
		is_for = 3
		
	else:
		 is_for = 2
		
	var info = preload("res://menu/gameplay_battle/ui/unit_floating_info/unit_floating_info.tscn").instance()
	info.is_for = is_for
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

func set_on_player_turn(v :bool):
	unit_control.visible = v
	loading_turn.visible = not v

func _show_battle_result():
	battle_result.visible = true
	game_ui.visible = false
	floating.visible = false
	loading_turn.visible = false
	
func show_win():
	_show_battle_result()
	battle_result_text.text = "Win"
	
func show_lose():
	_show_battle_result()
	battle_result_text.text = "Lose"
	
func _on_exit_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")

func _on_unit_control_end_turn():
	set_on_player_turn(false)
	emit_signal("end_turn")
	
func _on_unit_control_on_activate_ability():
	emit_signal("on_activate_ability")
	
