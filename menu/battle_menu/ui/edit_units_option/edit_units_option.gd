extends Control

signal close
 
const unit_selection_scene = preload("res://menu/gameplay_battle/ui/unit_control/unit_selection.tscn")
const item_scene = preload("res://menu/battle_menu/ui/edit_units_option/item/item.tscn")

onready var _selected_units = $Control/SafeArea/VBoxContainer/HBoxContainer2/selected_units
onready var _unit_pools = $Control/SafeArea/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/unit_pools

var player_data :PlayerBattleData
var unit_pools :Array

var unit_pools_class :Dictionary = {} # {int:[UnitData]}

func display():
	for i in _selected_units.get_children():
		_selected_units.remove_child(i)
		i.queue_free()
		
	for i in _unit_pools.get_children():
		_unit_pools.remove_child(i)
		i.queue_free()
		
	for i in player_data.player_units:
		var unit :UnitData = i
		var item = unit_selection_scene.instance()
		item.potrait = unit.unit_potrait
		item.connect("pressed", self, "_on_unit_remove", [unit])
		_selected_units.add_child(item)
		
	for i in 6 - player_data.player_units.size():
		var item = unit_selection_scene.instance()
		_selected_units.add_child(item)
		
	unit_pools_class.clear()
	
	for i in unit_pools:
		var unit :UnitData = i
		if unit in player_data.player_units:
			continue
			
		if not unit_pools_class.has(unit.unit_class):
			unit_pools_class[unit.unit_class] = []
			
		unit_pools_class[unit.unit_class].append(unit)
		
	for key in unit_pools_class.keys():
		var unit_class :int = key
		var item = item_scene.instance()
		item.units = unit_pools_class[key]
		item.unit_class = unit_class
		item.connect("on_unit_select", self, "_on_unit_pool_select")
		_unit_pools.add_child(item)
		
func _on_unit_remove(unit :UnitData):
	if player_data.player_units.empty():
		return
		
	player_data.player_units.erase(unit)
	display()
	
func _on_unit_pool_select(unit :UnitData):
	if player_data.player_units.size() >= 6:
		return
		
	player_data.player_units.append(unit)
	display()
	
func _on_back_pressed():
	if player_data.player_units.empty():
		return
		
	visible = false
	emit_signal("close")



