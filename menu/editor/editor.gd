extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var map = $map
onready var tile_highlight = $tile_highlight

func _ready():
	_load_or_generate_map()

func _load_or_generate_map():
	ui.movable_camera_ui.target = movable_camera
	var data:HexMapData.HexMapFileData = HexMapData.HexMapFileData.new()
	var d = SaveLoad.load_save("random.map")
	if d:
		data.from_dictionary(d)
		map.generate_from_data(data)
		
	else:
		map.generate_from_data(HexMapUtil.generate_empty_map())
		
	tile_highlight.visible = false
	
func _on_map_on_tile_click(tile):
	tile_highlight.translation = tile.global_position
	tile_highlight.visible = true

func _on_ui_on_tile_card_grab(pos :Vector2):
	tile_highlight.visible = true
	_on_ui_on_tile_card_draging(pos)

func _on_ui_on_tile_card_draging(pos :Vector2):
	var pos_v3 = Utils.screen_to_world(get_viewport().get_camera(), pos)
	var tile = map.get_closes_tile(pos_v3)
	tile_highlight.translation = tile.global_position

func _on_ui_on_tile_card_release(pos :Vector2, data:HexMapData.TileMapData):
	var pos_v3 = Utils.screen_to_world(get_viewport().get_camera(), pos)
	var tile = map.get_closes_tile(pos_v3)
	
	data.id = tile.id
	data.pos = tile.global_position
	data.rotation = tile.global_rotation
	
	map.update_spawn_tile(data)
	tile_highlight.visible = false

func _on_ui_on_tile_card_cancel():
	tile_highlight.visible = false
	
func _on_ui_on_save_map():
	var data:Dictionary = map.export_data().to_dictionary()
	SaveLoad.save("%s.map" % data.map_name, data)


