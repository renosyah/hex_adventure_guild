extends HexMapData
class_name ObjectMapData

var model :Resource

func from_dictionary(_data : Dictionary, repeated_string :Dictionary = {}):
	if _data.has("a"):
		var key = _data["a"]
		if repeated_string.has(key):
			model = load(repeated_string[key])
		else:
			model = load(_data["a"])
			
func to_dictionary(repeated_string :Dictionary = {null:null}) -> Dictionary :
	var data :Dictionary = {}
	if model:
		var path :String = model.resource_path
		if repeated_string.has(null):
			data["a"] = path
		else:
			var key :int = find_key_by_value(repeated_string, path)
			if key == -1:
				key = repeated_string.size()
				repeated_string[key] = path
				
			data["a"] = key
		
	return data
