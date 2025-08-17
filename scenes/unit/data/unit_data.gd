extends Resource
class_name UnitData

# owner
export var player_id :int
export var team :int

# info
export var unit_name :String
export var unit_potrait : Array # [int (column), int (row)]
export var unit_scene :Resource
export var pos :Vector3

# stats
export var action :int = 1
export var max_action :int = 1

export var move :int = 1
export var move_range :int = 1

export var hp :int = 25
export var max_hp :int = 25
export var armor :int = 2

export var attack_damage :int = 14
export var attack_range :int = 1

export var view_range :int = 2
export var move_speed :float = 0.4

func spawn(parent :Node) -> BaseUnit:
	var unit :BaseUnit = unit_scene.instance()
	unit.player_id = player_id
	unit.team = team
	unit.action = action
	unit.max_action = max_action
	unit.move = move
	unit.move_range = move_range
	unit.hp = hp
	unit.max_hp = max_hp
	unit.armor = armor
	unit.attack_damage = attack_damage
	unit.attack_range = attack_range
	unit.view_range = view_range
	unit.move_speed = move_speed
	parent.add_child(unit)
	unit.translation = pos
	return unit

