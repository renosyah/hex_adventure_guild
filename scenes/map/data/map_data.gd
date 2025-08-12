extends Resource
class_name HexMapData

class HexMapFileData:
	var map_name :String
	var map_size :int # (4, 6, 8)
	var tile_ids :Dictionary # { Vector2: int }
	var tiles : Array # [ TileMapData ]
	var navigation_map : Array # [ NavigationData ]
	
	func from_dictionary(_data : Dictionary):
		
		###
		map_name = _data["map_name"]
		map_size = _data["map_size"]
		
		tile_ids = {}
		for key in _data["tile_ids"].keys():
			tile_ids[key] = _data["tile_ids"][key]
		
		##
		tiles = [] # [ TileMapData ]
		for i in _data["tiles"]:
			var x :TileMapData = TileMapData.new()
			x.from_dictionary(i)
			tiles.append(x)
			
		navigation_map = _parse(_data["navigation_map"])
		
	func to_dictionary() -> Dictionary :
		var _data :Dictionary = {}
		
		###
		_data["map_name"] = map_name
		_data["map_size"] = map_size
		
		_data["tile_ids"] = {}
		for key in tile_ids.keys():
			_data["tile_ids"][key] = tile_ids[key]
			
		##
		_data["tiles"] = []
		for i in tiles:
			var x :TileMapData = i
			_data["tiles"].append(x.to_dictionary())
			
		_data["navigation_map"] = _encode(navigation_map)
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
	
const TileMapDataTypeLand = 1
const TileMapDataTypeWater = 2
const TileMapDataTypeHill = 3

class TileMapData:
	var id :Vector2
	var model :Resource
	var type :int
	var pos :Vector3
	var rotation :Vector3
	var object :ObjectMapData
	
	func from_dictionary(_data : Dictionary):
		id = _data["id"]
		
		if _data.has("model"):
			model = load(_data["model"])
			
		type = _data["type"]
		pos = _data["pos"]
		rotation = _data["rotation"]
		
		if _data.has("object"):
			object = ObjectMapData.new()
			object.from_dictionary(_data["object"])
		
	func to_dictionary() -> Dictionary :
		var data :Dictionary = {}
		data["id"] = id
		
		if model:
			data["model"] = model.resource_path
			
		data["type"] = type
		data["pos"] = pos
		data["rotation"] = rotation
		
		if object:
			data["object"] = object.to_dictionary()
			
		return data
		
class ObjectMapData:
	var model :Resource
	
	func from_dictionary(_data : Dictionary):
		if _data.has("model"):
			model = load(_data["model"])
		
	func to_dictionary() -> Dictionary :
		var data :Dictionary = {}
		if model:
			data["model"] = model.resource_path
		return data
		
class NavigationData:
	var id :Vector2
	var navigation_id :int
	var enable: bool
	var neighbors: Array #  [ int ]
	
	func from_dictionary(_data : Dictionary):
		navigation_id = _data["navigation_id"]
		id = _data["id"]
		enable = _data["enable"]
		neighbors = _data["neighbors"]
		
	func to_dictionary() -> Dictionary :
		var data :Dictionary = {}
		data["navigation_id"] = navigation_id
		data["id"] = id
		data["enable"] = enable
		data["neighbors"] = neighbors
		return data
