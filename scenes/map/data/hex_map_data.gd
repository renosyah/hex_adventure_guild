extends Resource
class_name HexMapData

const TileMapDataTypeLand = 1
const TileMapDataTypeWater = 2
const TileMapDataTypeHill = 3

func find_key_by_value(d :Dictionary, v :String) -> int:
	for i in d.keys():
		if d[i] == v:
			return i
		
	return -1
