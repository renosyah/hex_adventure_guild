extends Node
class_name BattleBot

signal bot_end_turn
signal bot_command_unit(_unit)

var chance_bot_attack :float = 0.5
var agresive_bot_attack :float = 0.7

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
	
func _create_paths_suggest() -> Array:
	var units :Array = unit_datas.keys().duplicate()
	units.shuffle()
	
	var _direction_suggest :Vector2 = units[0].current_tile
	
	for i in units:
		var target :BaseUnit = i
		if not is_instance_valid(target):
			continue
			
		if target.is_dead():
			continue
			
		if target.team == bot_team:
			continue
			
		var dis_1 = _direction_suggest.distance_squared_to(_selected_unit.current_tile)
		var dis_2 = target.current_tile.distance_squared_to(_selected_unit.current_tile)
		if dis_2 < dis_1:
			_direction_suggest = target.current_tile
			
	var cop = unit_blocked_tiles.duplicate()
	cop.erase(_direction_suggest)
	
	var results = map.get_navigation(_selected_unit.current_tile, _direction_suggest, cop)
	if results.empty() or results.size() == 1:
		return []
		
	var paths :Array = []
	for i in results:
		paths.append(i)
		
	paths.erase(_direction_suggest)
	if paths.size() == 1:
		return []

	while paths.size() > _selected_unit.move:
		paths.pop_back()

	return paths
	
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
	
	# 50 % chance to skip
	# sometime bot kindda frooze
#	if _rng.randf() < 0.5:
#		emit_signal("bot_end_turn")
#		return
	
	if _unit_to_command.empty():
		emit_signal("bot_end_turn")
		return
		
	_selected_unit = _unit_to_command.front()
	
	# make gunner use its reload ability
	# then move to next unit
	if _selected_unit is Gunner:
		if _selected_unit.can_use_ability():
			_selected_unit.use_ability()
			_unit_to_command.pop_front()
			return
			
	_add_unit_in_attack_range()
	
	emit_signal("bot_command_unit", _selected_unit)
	
	var decide_to_attack :bool = yield(_attack_unit(), "completed")
	if not decide_to_attack:
		var decide_to_move :bool = yield(_move_unit(), "completed")
		if decide_to_move:
			return
		
	if not _is_current_unit_can_stil_move():
		_unit_to_command.pop_front()
		
	bot_decide_timeout.start()
	
	
func _is_current_unit_can_stil_move() -> bool:
	if not _selected_unit.can_move():
		return false
		
	var _blocked_path = _undiscovered_tiles + unit_blocked_tiles
	var tiles = map.get_astar_adjacent_tile(_selected_unit.current_tile, _selected_unit.move, _blocked_path)
	if tiles.empty() or tiles.size() == 1:
		return false
		
	return true
	
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
	if not _selected_unit.has_action():
		return
		
	_option_to_attack.clear()
	
	var tiles = map.get_adjacent_tile(_selected_unit.current_tile, _selected_unit.get_attack_range())
	if tiles.empty():
		return
		
	for tile in tiles:
		var x :HexTile = tile
		if not unit_in_tile.has(tile.id):
			continue
			
		var _target :BaseUnit = unit_in_tile[tile.id]
		if _target.team == bot_team:
			continue
			
		_option_to_attack.append(_target)
		
func _attack_unit() -> bool:
	yield(get_tree(), "idle_frame")
	
	if _option_to_attack.empty():
		return false
		
	# have chance to attack or not
	if _rng.randf() > chance_bot_attack:
		return false
		
	var target :BaseUnit = _option_to_attack[_rng.randi_range(0, _option_to_attack.size() - 1)]
	_selected_unit.perfom_action_attack(target)
	
	yield(_selected_unit, "unit_attack_target")
	
	return true
	
func _move_unit() -> bool:
	yield(get_tree(), "idle_frame")
	
	if not _selected_unit.can_move():
		return false
		
	_reveal_tile_in_unit_view(_selected_unit.current_tile, _selected_unit.view_range)
	var _paths :Array = []
	
	if _rng.randf() < agresive_bot_attack:
		_paths = _create_paths_suggest()
	
	else:
		var movement_list = []
		var _blocked_path = _undiscovered_tiles + unit_blocked_tiles
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
		_paths = map.get_navigation(_selected_unit.current_tile, to, _blocked_path)
	
	if _paths.empty() or _paths.size() == 1:
		return false
	
	# dont include current tile id
	_paths.pop_front()
	
	var unit_paths = []
	for i in _paths:
		unit_paths.append([i, map.get_tile(i).global_position])
		_reveal_tile_in_unit_view(i, _selected_unit.view_range)
		
	_selected_unit.paths = unit_paths
	_selected_unit.move_unit()
	
	print("bot move unit : %s" % _selected_unit)
	
	yield(_selected_unit, "unit_reach")
	
	return true
	
func _reveal_tile_in_unit_view(id :Vector2, view_range :int):
	var tiles = map.get_adjacent_view_tile(id, view_range)
	for i in tiles:
		var tile :HexTile = i
		if _undiscovered_tiles.has(tile.id):
			_undiscovered_tiles.erase(tile.id)




