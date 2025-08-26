extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var map = $map
onready var tile_highlight = $tile_highlight
onready var timer = $Timer
onready var spawn_point = $spawn_point

var _tile_highlights = []
var _ranges = 2
var _spawn_point = []
var _closed_tile_highlights = []

func _ready():
	ui.movable_camera_ui.target = movable_camera
	tile_highlight.visible = false
	Global.connect("map_saved", self, "_on_save_map_done")
	_spawn_map()
	
func _spawn_map():
	var data = Global.selected_map_data
	var spawn_points = HexMapUtil.get_tile_spawn_point(data.tile_ids, Vector2.ZERO, data.map_size)
	for i in spawn_points:
		var ids :Array = i
		for id in ids:
			_spawn_point.append(id)
			
	map.generate_from_data(data, true)
	
func _on_map_on_map_ready():
	for id in _spawn_point:
		var x :HexTile = map.get_tile(id)
		x.set_discovered(true)
		
		var close = spawn_point.duplicate()
		close.visible = true
		add_child(close)
		close.translation = x.global_position
		close.translation.y += 0.14
		
		_closed_tile_highlights.append(close)
		
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
		if _spawn_point.has(x.id):
			continue
			
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
	
	# dont put anything
	# or change anything
	# on spawn point tiles
	if _spawn_point.has(tile.id):
		return
		
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
	var map_name = Global.selected_map_data.map_name
	var size =  Global.selected_map_data.map_size
	var seeding = rand_range(-1000, 1000)
	Global.selected_map_data = HexMapUtil.generate_randomize_map(seeding, size, _spawn_point)
	Global.selected_map_data.map_name = map_name
	map.generate_from_data(Global.selected_map_data, true)

func _on_ui_on_show_tile_label(v):
	map.show_tile_label(v)
	
func _save_ss(data :HexMapFileData) -> String:
	movable_camera.translation = Vector3(0, 12, 5)
	ui.set_visible(false)
	
	_clear_tile_highlights()
	tile_highlight.visible = false
	for i in _closed_tile_highlights:
		i.queue_free()
		yield(get_tree(),"idle_frame")
	
	var img: Image = get_viewport().get_texture().get_data()
	img.flip_y()
	
	var w = img.get_width()
	var h = img.get_height()
	var crop_rect = Rect2((w - 512)/2, (h - 512)/2, 512, 512)
	var img_path = "user://%s/%s.png" % [Global.map_dir, data.map_name]
	var cropped_img = Image.new()
	cropped_img.create(512, 512, false, img.get_format())
	cropped_img.blit_rect(img, crop_rect, Vector2(0,0))
	cropped_img.save_png(img_path)
	yield(get_tree(),"idle_frame")
	
	return img_path
	
func _on_ui_on_save_map():
	var dir_path = "user://%s/" % Global.map_dir
	var dir = Directory.new()
	if not dir.dir_exists(dir_path):
		dir.make_dir(dir_path)
	
	var data = map.export_data()
	var file_path = "user://%s/%s.map" % [Global.map_dir, data.map_name]
	
	var img_path = yield(_save_ss(data), "completed")
	_save_manifest(data, file_path, img_path)
	
	ui.set_visible(true)
	ui.loading.visible = true
	Global.save_map(file_path, data.to_dictionary(), false)
	
func _save_manifest(data :HexMapFileData, file_path :String, img :String):
	var path = "user://%s/%s.manifest" % [Global.map_dir, data.map_name]
	var m :HexMapFileManifest = HexMapFileManifest.new()
	m.map_name = data.map_name
	m.map_size = data.map_size
	m.map_image = img
	m.map_file_path = file_path
	SaveLoad.save(path, m.to_dictionary(), false)
	
func _on_save_map_done():
	yield(get_tree().create_timer(1),"timeout")
	ui.set_visible(true)
	ui.loading.visible = false
	



