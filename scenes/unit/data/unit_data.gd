extends Resource
class_name UnitData

const unit_class_peasant = 0
const unit_class_vanguard = 1
const unit_class_knight = 2
const unit_class_hunter = 3
const unit_class_gunner = 4
const unit_class_priest = 5
const unit_class_mage = 6

# owner
export var player_id :int
export var team :int

# info
export var unit_name :String
export var unit_potrait : Resource
export var unit_scene :Resource
export var pos :Vector3
export var unit_icon :Resource
export var unit_class :int

# stats
export var action :int = 1
export var max_action :int = 1

export var move :int = 1
export var move_range :int = 1

export var hp :int = 25
export var max_hp :int = 25
export var armor :int = 2

export var attack_damages :Array = [14]
export var attack_range :int = 1

export var view_range :int = 2
export var move_speed :float = 0.4

# equipment
export var weapon_model :Resource

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
	unit.attack_damages = attack_damages
	unit.attack_range = attack_range
	unit.view_range = view_range
	unit.move_speed = move_speed
	unit.weapon_model = weapon_model
	parent.add_child(unit)
	unit.translation = pos
	return unit

