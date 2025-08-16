extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var tile_highlight = $tile_highlight
onready var map = $map

var _tile_highlights = []

var _blocked_ids :Array = [] # [ Vector2 ]
var _units :Dictionary = {} # { Vector2 : BaseUnit }

var _selected_tile :HexTile
var _selected_unit :BaseUnit
var _move_tiles :Array = []

# Called when the node enter the scene tree for the first time.
func _ready():
	ui.movable_camera_ui.target = movable_camera
	map.generate_from_data(Global.selected_map_data, true)
	tile_highlight.visible = false

func _spawn_unit():
	var data = Global.selected_map_data
	var spawn_points = HexMapUtil.get_tile_spawn_point(data.tile_ids, Vector2.ZERO, data.map_size)
	var ids = spawn_points[3]
	for id in ids:
		var x :HexTile = map.get_tile(id)
		x.set_discovered(true)
		var unit = preload("res://scenes/unit/vanguard/vanguard.tscn").instance()
		unit.current_tile = id
		add_child(unit)
		unit.translation = x.global_position
		unit.connect("unit_enter_tile", self, "_on_unit_enter_tile")
		unit.connect("unit_leave_tile", self, "_on_unit_leave_tile")
		unit.connect("on_reach", self, "_on_unit_reach")
		_units[x.id] = unit
		
		_blocked_ids.append(unit.current_tile)

func _on_map_on_map_ready():
	_spawn_unit()
	
func _on_map_on_tile_click(tile :HexTile):
	_clear_tile_highlights()
	
	if _selected_unit == null:
		if not _units.has(tile.id):
			return
			
		_selected_unit = _units[tile.id]
		if not _selected_unit.can_move():
			_selected_unit = null
			_selected_tile = null
			return
			
		_selected_tile = tile
		higlight_unit_movement(tile.id)
		return
	
	if _selected_unit.current_tile == tile.id:
		_selected_unit = null
		_selected_tile = null
		return
		
	move_unit(tile.id)
		
func move_unit(to :Vector2):
	if _move_tiles.has(to):
		var paths :Array = map.get_navigation(_selected_tile.id, to, _blocked_ids)
		var unit_paths = []
		for i in paths:
			unit_paths.append([i, map.get_tile(i).global_position])
			
		unit_paths.pop_front()
		
		_selected_unit.paths = unit_paths
		_selected_unit.move_unit()
		_units.erase(_selected_tile.id)
		
	_selected_unit = null
	
func higlight_unit_movement(id :Vector2):
	if _selected_unit == null:
		return
		
	_move_tiles.clear()
	
	var tiles = map.get_astar_adjacent_tile(id, _selected_unit.move, _blocked_ids)
	tiles.pop_front()
	
	for tile in tiles:
		var x :HexTile = tile
		_move_tiles.append(x.id)
		_add_tile_highlights(x.global_position)
		

func _on_unit_enter_tile(_unit, _tile_id):
	if not _blocked_ids.has(_tile_id):
		_blocked_ids.append(_tile_id)
		
	# check if unit enter tile
	# trigger something
	# after finish
	
	print("enter : %s" % _tile_id)
	
	_unit.move_unit()
	
func _on_unit_leave_tile(_unit, _tile_id):
	if _blocked_ids.has(_tile_id):
		_blocked_ids.erase(_tile_id)
		
	print("leave : %s" % _tile_id)
	
func _on_unit_reach(_unit, _tile_id):
	_units[_tile_id] = _unit
	
func _process(delta):
	map.update_camera_position(movable_camera.global_position)
	
func _add_tile_highlights(pos :Vector3):
	var x = tile_highlight.duplicate()
	add_child(x)
	x.visible = true
	x.translation = pos
	x.show_move()
	_tile_highlights.append(x)
	
func _clear_tile_highlights():
	tile_highlight.visible = false
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
















