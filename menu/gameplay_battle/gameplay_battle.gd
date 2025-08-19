extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var tile_highlight_template = $tile_highlight
onready var map = $map
onready var cam :Camera = get_viewport().get_camera()
onready var damage_indicator = $damage_indicator
onready var simple_delay = $simple_delay

#------------------------------------ GLOBAL VAR ---------------------------------------------------
var _tile_highlights = []
var _undiscovered_tiles :Array = [] # [ Vector2 ]
var _unit_blocked_tiles :Array = [] # [ Vector2 ]
var _unit_in_tile :Dictionary = {} # { Vector2 : BaseUnit }
var _spawn_points :Array
var _unit_datas :Dictionary = {} # { BaseUnit : UnitData }
var _loots :Dictionary = {} # { Vector2 : Loot }
var _tile_to_scout :Array = []

#------------------------------------ SPECIAL CLASS ---------------------------------------------------

var _vanguard_units :Array = []

#------------------------------------ PLAYER VAR ---------------------------------------------------
var _selected_unit :BaseUnit
var _move_tiles :Array = []
var _attack_tiles :Array = []
var _unit_moving_path :Dictionary = {} # { Vector2 : tile_highlight_template }
var _total_enemy_unit :int = 0
var _total_player_unit :int = 0
var _last_cam_pos :Vector3
var _lock_control :bool = false

#------------------------------------ BOTS ---------------------------------------------------
const bot_scene = preload("res://bot/battle_bot.tscn")
var _bots = []

#------------------------------------ GODOT READY ---------------------------------------------------

# Called when the node enter the scene tree for the first time.
func _ready():
	_setup_ui()
	_setup_map()
	tile_highlight_template.visible = false
	
#------------------------------------ UI ---------------------------------------------------
func _setup_ui():
	ui.movable_camera_ui.target = movable_camera
	
func _display_detail_selected_unit():
	if not is_instance_valid(_selected_unit):
		return
		
	tile_highlight_template.translation = _selected_unit.global_position
	tile_highlight_template.visible = true
	ui.show_unit_detail(true, _selected_unit, _unit_datas[_selected_unit])
	
	if _selected_unit.player_id != Global.current_player_id:
		return
		
	if _selected_unit.can_move():
		_higlight_unit_movement(_selected_unit.current_tile)
	
	if _selected_unit.has_action():
		_higlight_unit_attack(_selected_unit.current_tile)
	
func _on_ui_end_turn():
	_last_cam_pos = movable_camera.global_position
	
	_clear_tile_highlights()
	_unit_moving_path.clear()
	
	# wait until all player
	# end their turn
	# then call on_turn() on your unit
	for i in _bots:
		var bot :BattleBot = i
		print("bot %s" % bot.bot_id)
		bot.on_turn()
		yield(bot, "bot_end_turn")
		
		
	# scout ability only
	# efect after a turn
	yield(_reveal_scout_tile(), "completed")
	
	for i in _unit_in_tile.values():
		var x :BaseUnit = i
		x.on_turn()
		
	movable_camera.global_position = _last_cam_pos
	ui.set_on_player_turn(true)

func _on_ui_on_activate_ability():
	if is_instance_valid(_selected_unit):
		if _selected_unit.has_action():
			_clear_tile_highlights()
			ui.show_unit_detail(false)
			_selected_unit.use_ability()
			_selected_unit = null
		
#------------------------------------ MAP ---------------------------------------------------
func _setup_map():
	map.generate_from_data(Global.selected_map_data, false)
	
func _process(delta):
	map.update_camera_position(movable_camera.global_position)
	ui.update_cam_position(cam)
	
func _on_map_on_map_ready():
	var data = Global.selected_map_data
	_spawn_points = HexMapUtil.get_tile_spawn_point(data.tile_ids, Vector2.ZERO, data.map_size, 2)
	_setup_undiscovered_tiles()
	_spawn_unit()
	
func _on_map_on_tile_click(tile :HexTile):
	if _lock_control:
		return
		
	if _undiscovered_tiles.has(tile.id):
		return
			
	_clear_tile_highlights()
	ui.show_unit_detail(false)
	
	var tile_has_unit :bool = _unit_in_tile.has(tile.id)
	if is_instance_valid(_selected_unit):
		if tile_has_unit:
			if _selected_unit != _unit_in_tile[tile.id]:
				
				if _attack_tiles.has(tile.id):
					_attack_target(_unit_in_tile[tile.id], tile.id)
					_selected_unit = null
					return
					
				_selected_unit = _unit_in_tile[tile.id]
				_display_detail_selected_unit()
				
			else:
				_selected_unit = null
				
		else:
			_move_unit(tile.id)
			_selected_unit = null
			
	else:
		if tile_has_unit:
			_selected_unit = _unit_in_tile[tile.id]
			_display_detail_selected_unit()
		
func _setup_undiscovered_tiles():
	for i in map.get_tiles():
		var tile :HexTile = i
		_undiscovered_tiles.append(tile.id)
	
#------------------------------------ UNITS ---------------------------------------------------
func _spawn_unit():
	var player_index = 0
	for i in Global.player_battle_data:
		var player :PlayerBattleData = i
		var tile_ids = _spawn_points[player_index]
		
		if player.player_id != Global.current_player_id:
			var bot = bot_scene.instance()
			bot.bot_id = player.player_id
			bot.bot_team = player.team
			bot.unit_blocked_tiles = _unit_blocked_tiles
			bot.unit_in_tile  = _unit_in_tile
			bot.unit_datas = _unit_datas
			bot.connect("bot_command_unit", self, "_on_bot_command_unit")
			bot.map = map
			add_child(bot)
			_bots.append(bot)
			
		var index :int = 0
		for unit_data in player.player_units:
			var data :UnitData = unit_data
			var tile_id :Vector2 = tile_ids[index]
			var is_player_unit = data.player_id == Global.current_player_id
			var hextile :HexTile = map.get_tile(tile_id)
			data.pos = hextile.global_position
			
			var unit :BaseUnit = data.spawn(self)
			unit.current_tile = tile_id
			unit.is_hidden = not is_player_unit
			unit.visible = not unit.is_hidden
			unit.connect("unit_take_damage", self, "_on_unit_take_damage")
			unit.connect("unit_enter_tile", self, "_on_unit_enter_tile")
			unit.connect("unit_leave_tile", self, "_on_unit_leave_tile")
			unit.connect("unit_reach", self, "_on_unit_reach")
			unit.connect("unit_dead", self, "_on_unit_dead", [data])
			
			if unit is Hunter:
				unit.connect("scouting", self , "_on_hunter_scouting", [unit])
			
			_unit_in_tile[tile_id] = unit
			_unit_datas[unit] = data
			
			if unit is Vanguard:
				_vanguard_units.append(unit)
			
			_unit_blocked_tiles.append(unit.current_tile)
			ui.add_unit_floating_info(unit)
			
			if is_player_unit:
				_last_cam_pos = hextile.global_position
				
			if unit_data.team == Global.current_player_id:
				_reveal_tile_in_unit_view(unit)
				_total_player_unit += 1
				
			if unit_data.team != Global.current_player_team:
				_total_enemy_unit += 1
				
			index += 1
			
		player_index+= 1
		
	movable_camera.translation = _last_cam_pos
	movable_camera.translation += Vector3.BACK * 8
	movable_camera.translation.y = 10
	
func _on_hunter_scouting(_unit :BaseUnit):
	var view = _unit.view_range + 1
	var clear_tiles :Array = HexMapUtil.get_adjacent_tile_common(_unit.current_tile, view)
	for i in clear_tiles:
		if not _tile_to_scout.has(i):
			_tile_to_scout.append(i)
	
func _attack_target(target :BaseUnit, to :Vector2):
	var conditions :Array = [
		not _attack_tiles.has(to),
		not _selected_unit.has_action(),
		not _unit_in_tile.has(to)
	]
	if conditions.has(true):
		return
		
	_selected_unit.perfom_action_attack(target)
	_attack_tiles.clear()
	
	ui.unit_control.visible = false
	_lock_control = true
	
	yield(_selected_unit, "unit_attack_target")
	
	_lock_control = false
	ui.unit_control.visible = true
	
func _move_unit(to :Vector2):
	var conditions :Array = [
		_selected_unit.player_id != Global.current_player_id,
		not _selected_unit.can_move(),
		not _move_tiles.has(to)
	]
	if conditions.has(true):
		return
		
	var _blocked_path = _undiscovered_tiles + _unit_blocked_tiles
	var paths :Array = map.get_navigation(_selected_unit.current_tile, to, _blocked_path)
	
	# dont include current tile id
	paths.pop_front()
	
	var unit_paths = []
	for i in paths:
		unit_paths.append([i, map.get_tile(i).global_position])
	
	_selected_unit.paths = unit_paths
	_selected_unit.move_unit()
	
	for id in paths:
		var x :HexTile = map.get_tile(id)
		var h = _add_tile_highlights(x.global_position, 3)
		_unit_moving_path[id] = h
		
	ui.unit_control.visible = false
	_lock_control = true
	
	yield(_selected_unit,"unit_reach")
	
	_lock_control = false
	ui.unit_control.visible = true
	
func _on_unit_take_damage(_unit :BaseUnit, _damage :int, _from_unit :BaseUnit):
	damage_indicator.translation = _unit.global_position
	damage_indicator.damage = _damage
	damage_indicator.show_damage()
	
func _on_unit_enter_tile(_unit :BaseUnit, _tile_id :Vector2):
	# unit will hidden
	# unit enter undiscovered tile
	# this is fo enemy unit
	_unit.is_hidden = _undiscovered_tiles.has(_tile_id)
	_unit.visible = not _unit.is_hidden
		
	if not _unit_blocked_tiles.has(_tile_id):
		_unit_blocked_tiles.append(_tile_id)
		print("enter : %s" % _tile_id)
		
	if _unit_moving_path.has(_tile_id):
		_unit_moving_path[_tile_id].queue_free()
		_unit_moving_path.erase(_tile_id)
		
	# check if unit enter tile
	# of vanguard unit with unit
	# ability activated
	for x in _vanguard_units:
		if x.is_enemy_enter_area(_unit, _tile_id):
			yield(_unit, "unit_take_damage")
			
			# must call stop
			# to notify the bot
			# its unit are fking dead
			if _unit.is_dead():
				_unit.on_unit_stop()
		
	if _unit.team == Global.current_player_team:
		_reveal_tile_in_unit_view(_unit)
		
	_unit.move_unit()
	
func _on_unit_leave_tile(_unit :BaseUnit, _tile_id :Vector2):
	if _unit_blocked_tiles.has(_tile_id):
		_unit_blocked_tiles.erase(_tile_id)
		print("leave : %s" % _tile_id)
	
	if _unit_in_tile.has(_tile_id):
		_unit_in_tile.erase(_tile_id)
	
func _on_unit_reach(_unit :BaseUnit, _tile_id :Vector2):
	_on_unit_enter_tile(_unit, _tile_id)
	
	_unit_in_tile[_tile_id] = _unit
	
	# picked loot
	# on arrive at tile
	if _loots.has(_tile_id):
		_loots[_tile_id].pick()
		
	for i in _bots:
		var bot :BattleBot = i
		bot.check_unit(_unit)
		
	print("reach : %s" % _tile_id)
	
func _on_unit_dead(_unit :BaseUnit, _tile_id :Vector2, data :UnitData):
	if _unit_in_tile.has(_tile_id):
		_unit_in_tile.erase(_tile_id)
		
	if _unit_blocked_tiles.has(_tile_id):
		_unit_blocked_tiles.erase(_tile_id)
		
	_unit.visible = false
	_spawn_grave(_tile_id, _unit.global_position)
	
	print("%s is dead" % data.unit_name)
	
	for key in _unit_moving_path.keys():
		_unit_moving_path[key].queue_free()
		
	_unit_moving_path.clear()
	
	for i in _bots:
		var bot :BattleBot = i
		bot.check_unit(_unit)
		
	damage_indicator.translation = _unit.global_position
	damage_indicator.show_dead()
	
	_update_battle_result(_unit.team)
	
func _reveal_tile_in_unit_view(_unit :BaseUnit):
	var tiles = map.get_adjacent_view_tile(_unit.current_tile, _unit.view_range)
	for i in tiles:
		var tile :HexTile = i
		tile.set_discovered(true)
		
		if _undiscovered_tiles.has(tile.id):
			_undiscovered_tiles.erase(tile.id)
			
		if _unit_in_tile.has(tile.id):
			_unit_in_tile[tile.id].unit_spotted()
			
#------------------------------------ UTILS ---------------------------------------------------
func _reveal_scout_tile():
	yield(get_tree(), "idle_frame")
	
	if _tile_to_scout.empty():
		return
		
	var mid_pos :Vector3 = _last_cam_pos
	var tiles :Array = []
	for id in _tile_to_scout:
		if not map.has_tile(id):
			continue
			
		var tile :HexTile = map.get_tile(id)
		tiles.append(tile)
		mid_pos += tile.global_position
	
	movable_camera.global_position = mid_pos / tiles.size()
	movable_camera.global_position += Vector3.BACK * 8
	movable_camera.global_position.y = _last_cam_pos.y
	
	for tile in tiles:
		tile.set_discovered(true)
		
		if _undiscovered_tiles.has(tile.id):
			_undiscovered_tiles.erase(tile.id)
			
		if _unit_in_tile.has(tile.id):
			_unit_in_tile[tile.id].unit_spotted()
			
		simple_delay.start()
		yield(simple_delay,"timeout")
		
	tiles.clear()
	_tile_to_scout.clear()
	
func _spawn_grave(id :Vector2, pos :Vector3):
	var grave = preload("res://scenes/loot/grave/grave.tscn").instance()
	grave.loot_type = grave.loot_type_money
	grave.value = int(rand_range(25,100))
	grave.loot_name = "Coin"
	add_child(grave)
	grave.translation = pos
	_loots[id] = grave
	
func _on_bot_command_unit(_unit :BaseUnit):
	if _unit.is_hidden:
		return
		
	movable_camera.translation = _unit.global_position
	movable_camera.translation += Vector3.BACK * 8
	movable_camera.translation.y = 10
		
func _higlight_unit_attack(id :Vector2):
	if not is_instance_valid(_selected_unit):
		return
		
	_attack_tiles.clear()
	
	var tiles = map.get_adjacent_tile(id, _selected_unit.attack_range)
	for tile in tiles:
		var x :HexTile = tile
		if not _unit_in_tile.has(tile.id):
			continue
			
		var _unit :BaseUnit = _unit_in_tile[tile.id]
		if _unit.team == Global.current_player_team:
			continue
			
		_attack_tiles.append(x.id)
		var h = _add_tile_highlights(x.global_position, 2)
		_tile_highlights.append(h)
	
func _higlight_unit_movement(id :Vector2):
	if not is_instance_valid(_selected_unit):
		return
		
	_move_tiles.clear()
	
	var _blocked_path = _undiscovered_tiles + _unit_blocked_tiles
	var tiles = map.get_astar_adjacent_tile(id, _selected_unit.move, _blocked_path)
	tiles.pop_front()
	
	for tile in tiles:
		var x :HexTile = tile
		_move_tiles.append(x.id)
		var h = _add_tile_highlights(x.global_position, 3)
		_tile_highlights.append(h)
		
func _add_tile_highlights(pos :Vector3, type :int = 0) -> Spatial:
	var x = tile_highlight_template.duplicate()
	add_child(x)
	x.visible = true
	x.translation = pos
	
	match (type):
		1:
			x.show()
		2:
			x.show_attack()
		3:
			x.show_move()
			
	return x
	
func _clear_tile_highlights():
	tile_highlight_template.visible = false
	for i in _tile_highlights:
		i.queue_free()
		
	_tile_highlights.clear()
	
func _update_battle_result(team :int):
	if team == Global.current_player_team:
		_total_player_unit -= 1
	else:
		_total_enemy_unit -= 1
	
	if _total_player_unit <= 0:
		ui.show_lose()
		
	elif _total_enemy_unit <= 0:
		ui.show_win()
















