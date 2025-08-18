extends Node
class_name BattleBot

signal bot_end_turn

var chance_bot_attack :float = 0.5

#------------------------------------ GLOBAL VAR ---------------------------------------------------
# ALL THIS VAR WILL SHARED POINTER WITH BATTLE SCENE
var bot_id = 1
var bot_team = 1
var unit_blocked_tiles :Array = [] # [ Vector2 ]
var unit_in_tile :Dictionary = {} # { Vector2 : BaseUnit }
var unit_datas :Dictionary = {} # { BaseUnit : UnitData }
var map :HexMap

#------------------------------------ BOT VAR ---------------------------------------------------
var _undiscovered_tiles :Array = [] # [ Vector2 ]
var _selected_unit :BaseUnit
var _move_tiles :Array = []
var _rng = RandomNumberGenerator.new()
var _unit_to_command :Array = []
var _option_to_attack :Array = []

onready var bot_decide_timeout = $bot_decide_timeout

func _ready():
	_setup_undiscovered_tiles()
	
func on_turn():
	_get_all_units()
	bot_decide_timeout.start()
	
func _setup_undiscovered_tiles():
	for i in map.get_tiles():
		var tile :HexTile = i
		_undiscovered_tiles.append(tile.id)
		
func _get_all_units():
	for key in unit_datas.keys():
		var unit :BaseUnit = key
		if not is_instance_valid(unit):
			continue
			
		if unit.is_dead():
			continue
			
		if unit.player_id == bot_id:
			 _unit_to_command.append(unit)
		
func _on_bot_decide_timeout_timeout():
	print("bot units : %s" % _unit_to_command.size())
	
	if _unit_to_command.empty():
		emit_signal("bot_end_turn")
		return
		
	_selected_unit = _unit_to_command.front()
	_add_unit_in_attack_range()
	
	if not _attack_unit():
		if _move_unit():
			return
	
	_unit_to_command.pop_front()
	bot_decide_timeout.start()

# this function will be call by battle scnene
# to inform bot if their current unit progress
# if unit dead or reach destination
func check_unit(unit :BaseUnit):
	if unit != _selected_unit:
		return
		
	if _unit_to_command.empty():
		emit_signal("bot_end_turn")
		return
		
	_unit_to_command.pop_front()
	bot_decide_timeout.start()
	
func _add_unit_in_attack_range():
	_option_to_attack.clear()
	
	var tiles = map.get_adjacent_tile(_selected_unit.current_tile, _selected_unit.attack_range)
	if tiles.empty() or tiles.size() == 1:
		return
		
	for tile in tiles:
		var x :HexTile = tile
		if not unit_in_tile.has(tile.id):
			continue
			
		var _target :BaseUnit = unit_in_tile[tile.id]
		if _target.team == bot_team:
			continue
			
		_option_to_attack.append(_target)
		
		
	tiles.pop_front()
	
func _attack_unit() -> bool:
	if _option_to_attack.empty():
		return false
		
	# have chance to attack or not
	if _rng.randf() > chance_bot_attack:
		return false
		
	var target :BaseUnit = _option_to_attack[_rng.randi_range(0, _option_to_attack.size() - 1)]
	_selected_unit.perfom_action_attack(target)
	
	return true
	
func _move_unit() -> bool:
	_reveal_tile_in_unit_view(_selected_unit.current_tile, _selected_unit.view_range)
	
	var _blocked_path = _undiscovered_tiles + unit_blocked_tiles
	var movement_list = []
	
	var tiles = map.get_astar_adjacent_tile(_selected_unit.current_tile, _selected_unit.move, _blocked_path)
	if tiles.empty() or tiles.size() == 1:
		return false
		
	_reveal_tile_in_unit_view(tiles.front().id, _selected_unit.view_range)
	tiles.pop_front()
	
	for tile in tiles:
		var x :HexTile = tile
		movement_list.append(x.id)
		
	if movement_list.empty():
		return false
		
	var to = movement_list[_rng.randi_range(0, movement_list.size() - 1)]
	var paths :Array = map.get_navigation(_selected_unit.current_tile, to, _blocked_path)
	if paths.empty() or paths.size() == 1:
		return false
	
	# dont include current tile id
	paths.pop_front()
	
	var unit_paths = []
	for i in paths:
		unit_paths.append([i, map.get_tile(i).global_position])
		_reveal_tile_in_unit_view(i, _selected_unit.view_range)
		
	_selected_unit.paths = unit_paths
	_selected_unit.move_unit()
	
	print("bot move unit : %s" % _selected_unit)
	
	return true
	
func _reveal_tile_in_unit_view(id :Vector2, view_range :int):
	var tiles = map.get_adjacent_view_tile(id, view_range)
	for i in tiles:
		var tile :HexTile = i
		if _undiscovered_tiles.has(tile.id):
			_undiscovered_tiles.erase(tile.id)




