extends HexMapData
class_name HexMapFileManifest

var map_name :String
var map_size :int
var map_image :String
var map_file_path :String

func from_dictionary(_data : Dictionary):
	map_name = _data["map_name"]
	map_size = _data["map_size"]
	map_image = _data["map_image"]
	map_file_path = _data["map_file_path"]

func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["map_name"] = map_name
	_data["map_size"] = map_size
	_data["map_image"] = map_image
	_data["map_file_path"] = map_file_path
	return _data
