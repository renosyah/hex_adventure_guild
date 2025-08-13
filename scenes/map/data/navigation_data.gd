extends HexMapData
class_name NavigationData

var id :Vector2
var navigation_id :int
var enable: bool
var neighbors: Array #  [ int ]

func from_dictionary(_data : Dictionary):
	navigation_id = _data["a"]
	id = _data["b"]
	enable = _data["c"]
	neighbors = _data["d"]
	
func to_dictionary() -> Dictionary :
	var data :Dictionary = {}
	data["a"] = navigation_id
	data["b"] = id
	data["c"] = enable
	data["d"] = neighbors
	return data
