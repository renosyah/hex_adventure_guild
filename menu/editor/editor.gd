extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var map = $map
onready var tile_highlight = $tile_highlight
onready var timer = $Timer

var _tile_highlights = []
var _ranges = 2

func _ready():
	ui.movable_camera_ui.target = movable_camera
	
	var d = SaveLoad.load_save("random.map")
	if d:
		var x = HexMapFileData.new()
		x.from_dictionary(d)
		map.generate_from_data(x)
	else:
		map.generate_from_data(Global.selected_map_data)
		
	tile_highlight.visible = false
	
func _process(delta):
	map.update_camera_position(movable_camera.global_position)
	
func _add_tile_highlights(pos :Vector3, type :int):
	var x = tile_highlight.duplicate()
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
			
	_tile_highlights.append(x)
	
func _clear_tile_highlights():
	for i in _tile_highlights:
		i.queue_free()
		
	_tile_highlights.clear()
	
func _on_map_on_tile_click(tile :HexTile):
	_clear_tile_highlights()
	
	var tiles = []
	var type = 1
	var btns = ui.get_nav_option_buttons()
	
	if btns[0].is_toggled():
		type = 1
		tiles = map.get_adjacent_tile(tile.id, _ranges)
	elif btns[1].is_toggled():
		type = 2
		tiles = map.get_adjacent_view_tile(tile.id, _ranges)
	elif btns[2].is_toggled():
		type = 3
		tiles = map.get_astar_adjacent_tile(tile.id, _ranges)
	
	tiles.erase(tile)
	tile_highlight.visible = true
	tile_highlight.translation = tile.global_position
	
	for i in tiles:
		var x :HexTile = i
		_add_tile_highlights(x.global_position, type)
		
	timer.start()

func _on_ui_on_tile_card_grab(pos :Vector2):
	_clear_tile_highlights()
	tile_highlight.visible = true
	_on_ui_on_tile_card_draging(pos)

func _on_ui_on_tile_card_draging(pos :Vector2):
	var pos_v3 = Utils.screen_to_world(get_viewport().get_camera(), pos)
	var tile = map.get_closes_tile(pos_v3)
	tile_highlight.translation = tile.global_position

func _on_ui_on_tile_card_release(pos :Vector2, data:TileMapData):
	var pos_v3 = Utils.screen_to_world(get_viewport().get_camera(), pos)
	var tile = map.get_closes_tile(pos_v3)
	
	data.id = tile.id
	data.pos = tile.global_position
	data.rotation = tile.global_rotation
	
	map.update_spawn_tile(data)
	tile_highlight.visible = false
	
	var enable_nav = data.object == null && data.type != HexMapData.TileMapDataTypeWater
	map.update_navigation_tile(tile.id, enable_nav)
	
func _on_ui_on_tile_card_cancel():
	tile_highlight.visible = false
	
func _on_Timer_timeout():
	_clear_tile_highlights()
	tile_highlight.visible = false
	
func _on_ui_on_change_range(v):
	_ranges = v
	
func _on_ui_on_randomize_map():
	_on_Timer_timeout()
	var seeding = rand_range(-1000, 1000)
	map.generate_from_data(HexMapUtil.generate_randomize_map(seeding))

func _on_ui_on_show_tile_label(v):
	map.show_tile_label(v)
	
func _on_ui_on_save_map():
	var data = map.export_data()
	SaveLoad.save("%s.map" % data.map_name, data.to_dictionary())









