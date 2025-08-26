extends Node
class_name UnitUtils

static func get_unit_datas() -> Array:
	var res = []
	var units = Utils.get_all_resources("res://scenes/unit/data/units/")
	for i in units:
		res.append(load(i))
	return res
	
static func create_unit_name(clas :int) -> String:
	var nam = RandomNameGenerator.generate_name()
	match clas:
		UnitData.unit_class_peasant:
			return "%s (Peasant)" % nam
		UnitData.unit_class_vanguard:
			return "%s (Vanguard)" % nam
		UnitData.unit_class_knight:
			return "Sir %s (Knight)" % nam
		UnitData.unit_class_hunter:
			return "%s (Hunter)" % nam
		UnitData.unit_class_gunner:
			return "%s (Gunner)" % nam
		UnitData.unit_class_mage:
			return "Master %s (Mage)" % nam
		UnitData.unit_class_priest:
			return "Master %s (Priest)" % nam
			
	return nam
	
const vanguard_weapons = {
	preload("res://scenes/unit/vanguard/glaive.png") : [6,8,12],
	preload("res://scenes/unit/vanguard/pike.png") : [5,7,9],
	preload("res://scenes/unit/vanguard/spear.png") : [4,5,6],
}
const knight_weapons = {
	preload("res://scenes/unit/knight/axe.png") : [3,4,5,6,7,8],
	preload("res://scenes/unit/knight/sword.png") : [4,4,5,8,9,9],
	preload("res://scenes/unit/knight/war_hammer.png") : [4,6,7,8,9,12],
}
static func set_unit_attack_damages(data :UnitData) -> Array:
	match data.unit_class:
		UnitData.unit_class_vanguard:
			return vanguard_weapons[data.weapon_model]
		UnitData.unit_class_knight:
			return knight_weapons[data.weapon_model]
			
	return data.attack_damages
	
static func set_unit_weapon(data :UnitData) -> Resource:
	match data.unit_class:
		UnitData.unit_class_vanguard:
			return vanguard_weapons.keys()[rand_range(0, 3)]
		UnitData.unit_class_knight:
			return knight_weapons.keys()[rand_range(0, 3)]
			
	return data.weapon_model
	
static func create_unit_potrait(clas :int) -> AtlasTexture:
	match clas:
		UnitData.unit_class_peasant, UnitData.unit_class_priest:
			var potraits = [
				[1, 0],[0, 1], [2, 2],
				[0, 3],[2, 3], [1, 5]
			]
			var pot = potraits[rand_range(0, 6)]
			return PotraitGenerator.get_soldier_potrait(pot[0], pot[1])
		UnitData.unit_class_vanguard:
			var potraits = [
				[2,0],[3, 0],[2, 1]
			]
			var pot = potraits[rand_range(0, 3)]
			return PotraitGenerator.get_soldier_potrait(pot[0], pot[1])
			
		UnitData.unit_class_knight:
			return PotraitGenerator.get_soldier_potrait(1, 2)
			
		UnitData.unit_class_hunter,UnitData.unit_class_gunner:
			var potraits = [
				[0, 0],[0, 2],[1, 1],
				[1, 1],[2, 1],[3, 1],
				[0, 2],[1, 3],[3, 3],
			]
			var pot = potraits[rand_range(0, 9)]
			return PotraitGenerator.get_soldier_potrait(pot[0], pot[1])
			
		UnitData.unit_class_mage:
			return PotraitGenerator.get_soldier_potrait(0, int(rand_range(0,5)))
			
	return PotraitGenerator.get_soldier_potrait(int(rand_range(0,3)), int(rand_range(0,5)))
