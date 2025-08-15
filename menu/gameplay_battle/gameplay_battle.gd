extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var tile_highlight = $tile_highlight
onready var map = $map

var _tile_highlights = []
var _selected_tile :HexTile
onready var vanguard = $vanguard

# Called when the node enter the scene tree for the first time.
func _ready():
	ui.movable_camera_ui.target = movable_camera
	map.generate_from_data(Global.selected_map_data, true)
	tile_highlight.visible = false

func _on_map_on_map_ready():
	var data = Global.selected_map_data
	var spawn_points = HexMapUtil.get_tile_spawn_point(data.tile_ids, Vector2.ZERO, data.map_size)
	for id in spawn_points:
		var x :HexTile = map.get_tile(id)
		x.set_discovered(true)
		
	vanguard.current_tile = spawn_points[0]
	vanguard.translation = map.get_tile(spawn_points[0]).global_position
	
func _on_map_on_tile_click(tile :HexTile):
	var navs = map.get_navigation(vanguard.current_tile, tile.id)
	var paths = []
	for id in navs:
		paths.append([id, map.get_tile(id).global_position])

	vanguard.paths = paths
	vanguard.move()

	_selected_tile = null

func _on_vanguard_unit_enter_tile(_unit, _tile_id):
	
	# check if unit enter tile
	# trigger something
	# after finish
	
	vanguard.move()
	
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


