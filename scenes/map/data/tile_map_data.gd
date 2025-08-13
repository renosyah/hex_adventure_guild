extends HexMapData
class_name TileMapData

var id :Vector2
var model :Resource
var type :int
var pos :Vector3
var rotation :Vector3
var object :ObjectMapData

func from_dictionary(_data : Dictionary, repeated_string :Dictionary = {}):
	id = _data["a"]
	
	if _data.has("b"):
		var key = _data["b"]
		if repeated_string.has(key):
			model = load(repeated_string[key])
		else:
			model = load(_data["b"])
		
	type = _data["c"]
	pos = _data["d"]
	rotation = _data["e"]
	
	if _data.has("f"):
		object = ObjectMapData.new()
		object.from_dictionary(_data["f"], repeated_string)
	
func to_dictionary(repeated_string :Dictionary = {null:null}) -> Dictionary :
	var data :Dictionary = {}
	data["a"] = id
	
	if model:
		var path :String = model.resource_path
		if repeated_string.has(null):
			data["b"] = path
			
		else:
			var key :int = find_key_by_value(repeated_string, path)
			if key == -1:
				key = repeated_string.size()
				repeated_string[key] = path
				
			data["b"] = key
		
	data["c"] = type
	data["d"] = pos
	data["e"] = rotation
	
	if object:
		data["f"] = object.to_dictionary(repeated_string)
		
	return data
