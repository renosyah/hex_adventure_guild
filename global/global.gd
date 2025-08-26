extends Node

signal map_loaded
signal map_saved

func _ready():
	_init_save_load_map()
	
#---------------------------------------------------------------------------------------
	
var current_player_id = 1
var current_player_team = 1

var player_battle_data :Array = [] # [ PlayerBattleData ]

#---------------------------------------------------------------------------------------
const map_dir = "map"
var selected_map_data : HexMapFileData
var _save_load_map :SaveLoadImproved

func _init_save_load_map():
	_save_load_map = preload("res://addons/save_load/save_load_improve.tscn").instance()
	add_child(_save_load_map)
	_save_load_map.connect("save_done", self ,"_save_map_done")
	_save_load_map.connect("load_done", self ,"_load_map_done")
	
func save_map(filename :String, data, use_prefix = true):
	var path = "%s/%s" %[map_dir, filename] if use_prefix else filename
	_save_load_map.save_data_async(path, data, use_prefix)
	
func load_map(filename :String, use_prefix = true) -> bool:
	var path = "%s/%s" %[map_dir, filename] if use_prefix else filename
	var exist :bool = _save_load_map.file_exists(path, use_prefix)
	if exist:
		_save_load_map.load_data_async(path, use_prefix)
		
	return exist
	
func _save_map_done(success :bool):
	if success:
		emit_signal("map_saved")
	
func _load_map_done(success :bool, data):
	if success:
		selected_map_data = HexMapFileData.new()
		selected_map_data.from_dictionary(data)
		emit_signal("map_loaded")
#---------------------------------------------------------------------------------------



