extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var tile_highlight_template = $tile_highlight
onready var map = $map

var _tile_highlights = []
var _undiscovered_tiles :Array = [] # [ Vector2 ]
var _unit_blocked_tiles :Array = [] # [ Vector2 ]
var _units :Dictionary = {} # { Vector2 : BaseUnit }
var _spawn_points :Array

var _unit_datas :Dictionary = {} # { BaseUnit : UnitData }
var _selected_tile :HexTile
var _selected_unit :BaseUnit
var _move_tiles :Array = []
var _unit_moving_path :Dictionary = {} # { Vector2 : tile_highlight_template }

# Called when the node enter the scene tree for the first time.
func _ready():
	ui.movable_camera_ui.target = movable_camera
	map.generate_from_data(Global.selected_map_data, false)
	tile_highlight_template.visible = false
	
func _process(delta):
	map.update_camera_position(movable_camera.global_position)
	
func _on_map_on_map_ready():
	var data = Global.selected_map_data
	_spawn_points = HexMapUtil.get_tile_spawn_point(data.tile_ids, Vector2.ZERO, data.map_size)
	_setup_undiscovered_tiles()
	_spawn_unit()
	
func _spawn_unit():
	var tile_ids = _spawn_points[Global.team]
	var index :int = 0
	for tile_id in tile_ids:
		var x :HexTile = map.get_tile(tile_id)
		x.set_discovered(true)
		
		var data :UnitData = Global.player_units[index]
		data.pos = x.global_position
		var unit :BaseUnit = data.spawn(self)
		unit.current_tile = tile_id
		unit.connect("unit_enter_tile", self, "_on_unit_enter_tile")
		unit.connect("unit_leave_tile", self, "_on_unit_leave_tile")
		unit.connect("unit_reach", self, "_on_unit_reach")
		_units[tile_id] = unit
		_unit_datas[unit] = data
		
		_unit_blocked_tiles.append(unit.current_tile)
		_reveal_tile_in_unit_view(unit)
		index += 1
		
func _setup_undiscovered_tiles():
	for i in map.get_tiles():
		var tile :HexTile = i
		var conditions = [
			# if already discovered
			# skip it
			tile.is_discovered,
			
			# unit ocupied tile
			# dont include it
			 _units.has(tile.id),
			
			# this is very important
			# because tile already blocked by nav
			# dont include it
			map.is_blocked_nav_tile(tile.id)
		]
		if conditions.has(true):
			continue
		
		_undiscovered_tiles.append(tile.id)
	
func _reveal_tile_in_unit_view(_unit :BaseUnit):
	var tiles = map.get_adjacent_view_tile(_unit.current_tile, _unit.view_range)
	for i in tiles:
		var tile :HexTile = i
		if not tile.is_discovered:
			tile.set_discovered(true)
			
		if _undiscovered_tiles.has(tile.id):
			_undiscovered_tiles.erase(tile.id)
	
	
func _on_map_on_tile_click(tile :HexTile):
	if not tile.is_discovered:
		return
		
	_clear_tile_highlights()
	ui.show_unit_detail(false)
	
	if _selected_unit == null:
		if not _units.has(tile.id):
			return
			
		_selected_unit = _units[tile.id]
		
		tile_highlight_template.translation = _selected_unit.global_position
		tile_highlight_template.visible = true
		ui.show_unit_detail(true, _unit_datas[_selected_unit])
		
		if not _selected_unit.can_move():
			return
			
		_selected_tile = tile
		_higlight_unit_movement(tile.id)
		return
	
	if _selected_unit.current_tile == tile.id:
		_selected_unit = null
		_selected_tile = null
		return
		
	_move_unit(tile.id)
	
func _move_unit(to :Vector2):
	if not _selected_unit.can_move():
		_selected_unit = null
		_selected_tile = null
		return
		
	if _move_tiles.has(to):
		var _blocked_path = _undiscovered_tiles + _unit_blocked_tiles
		var paths :Array = map.get_navigation(_selected_tile.id, to, _blocked_path)
		
		# dont include current tile id
		paths.pop_front()
		
		var unit_paths = []
		for i in paths:
			unit_paths.append([i, map.get_tile(i).global_position])
		
		_selected_unit.paths = unit_paths
		_selected_unit.move_unit()
		_units.erase(_selected_tile.id)
		
		for id in paths:
			var x :HexTile = map.get_tile(id)
			var h = _add_tile_highlights(x.global_position, 3)
			_unit_moving_path[id] = h
			
	_selected_unit = null
	
func _higlight_unit_movement(id :Vector2):
	if _selected_unit == null:
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
		
	
func _on_unit_enter_tile(_unit, _tile_id):
	if not _unit_blocked_tiles.has(_tile_id):
		_unit_blocked_tiles.append(_tile_id)
		print("enter : %s" % _tile_id)
		
	if _unit_moving_path.has(_tile_id):
		_unit_moving_path[_tile_id].queue_free()
		_unit_moving_path.erase(_tile_id)
		
	# check if unit enter tile
	# trigger something
	# after finish
	for i in _units.values():
		if i is Vanguard:
			var x :Vanguard = i
			if x.is_enemy_enter_area(_unit):
				yield(x, "unit_attack_target")
		
	_reveal_tile_in_unit_view(_unit)
	_unit.move_unit()
	
func _on_unit_leave_tile(_unit, _tile_id):
	if _unit_blocked_tiles.has(_tile_id):
		_unit_blocked_tiles.erase(_tile_id)
		print("leave : %s" % _tile_id)
		
func _on_unit_reach(_unit, _tile_id):
	_units[_tile_id] = _unit
	
func _add_tile_highlights(pos :Vector3, type :int = 0) -> Spatial:
	var x = tile_highlight_template.duplicate()
	add_child(x)
	x.visible = true
	x.translation = pos
	
	match (type):
		1:
			x.show()
		2:
			x.show_view()
		3:
			x.show_move()
			
	return x
	
func _clear_tile_highlights():
	tile_highlight_template.visible = false
	for i in _tile_highlights:
		i.queue_free()
		
	_tile_highlights.clear()
	
func _on_ui_end_turn():
	
	# waiit until all player
	# end their turn
	# then call on_turn() on your unit
	
	for i in _units.values():
		var x :BaseUnit = i
		x.on_turn()

func _on_ui_on_activate_ability():
	if _selected_unit:
		_clear_tile_highlights()
		ui.show_unit_detail(false)
		(_selected_unit as Vanguard).perfom_action_activate_spear_defence()
		_selected_unit = null
		_selected_tile = null

















