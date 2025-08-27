extends Spatial
class_name Loot

const loot_type_none = 0
const loot_type_money = 1
const loot_type_consumable = 2

export var loot_type :int
export var loot_name :String
export var value :int
export var destroy_on_pick :bool = false

var _already_loot :bool = false

func pick():
	if _already_loot:
		return
		
	_already_loot = true
	
	if destroy_on_pick:
		queue_free()
	
