extends Node

signal map_loaded
signal map_saved

var selected_map_data : HexMapFileData
var _save_load_map :SaveLoadImproved

func _ready():
	_init_save_load_map()
	
func _init_save_load_map():
	_save_load_map = preload("res://addons/save_load/save_load_improve.tscn").instance()
	add_child(_save_load_map)
	_save_load_map.connect("save_done", self ,"_save_map_done")
	_save_load_map.connect("load_done", self ,"_load_map_done")
	
func save_map(filename :String, data):
	_save_load_map.save_data_async(filename, data)
	
func load_map(filename :String) -> bool:
	var exist :bool = _save_load_map.file_exists(filename)
	if exist:
		_save_load_map.load_data_async(filename)
		
	return exist
	
func _save_map_done(success :bool):
	if success:
		emit_signal("map_saved")
	
func _load_map_done(success :bool, data):
	if success:
		selected_map_data = HexMapFileData.new()
		selected_map_data.from_dictionary(data)
		emit_signal("map_loaded")
	
