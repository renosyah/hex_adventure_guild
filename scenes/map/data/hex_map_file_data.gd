extends HexMapData
class_name HexMapFileData

var map_name :String
var map_size :int # (4, 6, 8)
var tile_ids :Dictionary # { Vector2: int }
var tiles : Array # [ TileMapData ]
var navigation_map : Array # [ NavigationData ]

# store string duplicate value
# save to this return it key
# if it exist return it key
# to get it just get via key
var repeated_string :Dictionary

func from_dictionary(_data : Dictionary):
	
	###
	map_name = _data["a"]
	map_size = _data["b"]
	repeated_string = _data["c"]
	
	tile_ids = {}
	for key in _data["d"].keys():
		tile_ids[key] = _data["d"][key]
	
	##
	tiles = [] # [ TileMapData ]
	for i in _data["e"]:
		var x :TileMapData = TileMapData.new()
		x.from_dictionary(i, repeated_string)
		tiles.append(x)
		
	navigation_map = _parse(_data["f"])
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	
	###
	_data["a"] = map_name
	_data["b"] = map_size
	
	_data["c"] = repeated_string
	
	_data["d"] = {}
	for key in tile_ids.keys():
		_data["d"][key] = tile_ids[key]
		
	##
	_data["e"] = []
	for i in tiles:
		var x :TileMapData = i
		_data["e"].append(x.to_dictionary(repeated_string))
		
	_data["f"] = _encode(navigation_map)
	return _data
	
func _parse(v) -> Array:
	var list = []
	for i in v:
		var x :NavigationData = NavigationData.new()
		x.from_dictionary(i)
		list.append(x)
		
	return list
		
func _encode(v) -> Array:
	var list = []
	for i in v:
		var x :NavigationData = i
		list.append(x.to_dictionary())
	return list
	
