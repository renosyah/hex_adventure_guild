extends Control

signal on_unit_select(unit)
signal on_activate_ability
signal end_turn
signal surender

const unit_selection_scene = preload("res://menu/gameplay_battle/ui/unit_control/unit_selection.tscn")

onready var game_ui = $CanvasLayer/Control/SafeArea/VBoxContainer
onready var unit_control = $CanvasLayer/Control/SafeArea/VBoxContainer/unit_control
onready var movable_camera_ui = $CanvasLayer/Control/SafeArea/VBoxContainer/movable_camera_ui
onready var floating = $CanvasLayer/Control/floating
onready var loading_turn = $CanvasLayer/Control/loading
onready var battle_result = $CanvasLayer/Control/SafeArea/battle_result
onready var battle_result_text = $CanvasLayer/Control/SafeArea/battle_result/MarginContainer/VBoxContainer/battle_result_text
onready var units = $CanvasLayer/Control/SafeArea/units
onready var units_container = $CanvasLayer/Control/SafeArea/units/VBoxContainer
onready var dialog_menu = $CanvasLayer/Control/dialog_menu

var floating_infos :Dictionary = {} # {unit :floating info}

func _ready():
	loading_turn.visible = false
	battle_result.visible = false
	dialog_menu.visible = false
	
func add_unit_to_selection(unit :BaseUnit, data :UnitData):
	var unit_selection = unit_selection_scene.instance()
	unit_selection.potrait = data.unit_potrait
	unit_selection.connect("pressed", self, "_on_select_unit", [unit])
	units_container.add_child(unit_selection)
	units_container.move_child(unit_selection, 0)
	
	unit.connect("unit_dead", self , "_on_unit_dead", [unit_selection])
	unit.connect("unit_selected", self, "_on_unit_selected", [unit, unit_selection])
	unit.connect("unit_on_turn", self, "_on_unit_update_action_status", [unit_selection])
	unit.connect("unit_consume_action", self, "_on_unit_update_action_status", [unit_selection])
	
func show_unit_detail(v :bool, unit :BaseUnit = null, data :UnitData = null):
	unit_control.show_unit_detail(v, unit, data)
	
func add_unit_floating_info(unit :BaseUnit):
	var is_for = 1
	
	var is_player_unit = unit.player_id == Global.current_player_id
	var is_team = not is_player_unit and unit.team == Global.current_player_team
	
	if is_player_unit:
		is_for = 1
		
	elif is_team:
		#is_for = 3
		return
		
	else:
		 is_for = 2
		
	var info = preload("res://menu/gameplay_battle/ui/unit_floating_info/unit_floating_info.tscn").instance()
	info.is_for = is_for
	info.is_player = unit.player_id == Global.current_player_id
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
		info.visible = unit.visible and not unit.is_hidden
		var v2 = camera.unproject_position(pos)
		info.rect_position = v2 - info.rect_pivot_offset

func set_on_player_turn(v :bool):
	unit_control.visible = v
	loading_turn.visible = not v
	units.visible = v and game_ui.visible

func _show_battle_result():
	battle_result.visible = true
	game_ui.visible = false
	floating.visible = false
	loading_turn.visible = false
	units.visible = false
	
func show_win():
	_show_battle_result()
	battle_result_text.text = "Win"
	
func show_lose():
	_show_battle_result()
	battle_result_text.text = "Lose"
	
func _on_unit_update_action_status(unit :BaseUnit, unit_selection):
	unit_selection.can_action(unit.has_action())
	
func _on_unit_dead(_unit, _tile_id, unit_selection):
	unit_selection.set_dead()

func _on_select_unit(unit :BaseUnit):
	if unit.is_dead():
		return
		
	emit_signal("on_unit_select", unit)

func _on_unit_selected(unit :BaseUnit, _selection):
	_selection.select(unit.is_selected)

func _on_unit_control_end_turn():
	set_on_player_turn(false)
	emit_signal("end_turn")
	
func _on_unit_control_on_activate_ability():
	emit_signal("on_activate_ability")
	
func _on_unit_control_on_unit_select(unit):
	emit_signal("on_unit_select", unit)
	
func _on_menu_pressed():
	dialog_menu.visible = true
	
func _on_dialog_menu_exit():
	get_tree().change_scene("res://menu/main/main.tscn")

func _on_dialog_menu_surrender():
	dialog_menu.visible = false
	show_lose()

func _on_exit_pressed():
	_on_dialog_menu_exit()





