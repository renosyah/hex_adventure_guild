extends Node
class_name UnitUtils

static func get_all_unit_resource() -> Array:
	var res = []
	var units = Utils.get_all_resources("res://scenes/unit/data/units/")
	for i in units:
		res.append(load(i))
	return res
	
static func create_unit_name(clas :int) -> String:
	var nam = RandomNameGenerator.generate_name()
	match clas:
		UnitData.unit_class_vanguard:
			return "%s (Vanguard)" % nam
		UnitData.unit_class_knight:
			return "Sir %s (Knight)" % nam
		UnitData.unit_class_hunter:
			return "%s (Hunter)" % nam
		UnitData.unit_class_gunner:
			return "%s (Gunner)" % nam
		UnitData.unit_class_mage, UnitData.unit_class_priest:
			return "Master %s (Mage)" % nam
			
	return nam
	
const vanguard_weapons = {
	preload("res://scenes/unit/vanguard/glaive.png") : 24,
	preload("res://scenes/unit/vanguard/pike.png") : 18,
	preload("res://scenes/unit/vanguard/spear.png") : 14
}
const knight_weapons = {
	preload("res://scenes/unit/knight/axe.png") : 18,
	preload("res://scenes/unit/knight/sword.png") : 24,
	preload("res://scenes/unit/knight/war_hammer.png") : 28
}
static func set_unit_attack_damage(data :UnitData) -> int:
	match data.unit_class:
		UnitData.unit_class_vanguard:
			return vanguard_weapons[data.weapon_model]
		UnitData.unit_class_knight:
			return knight_weapons[data.weapon_model]
			
	return data.attack_damage
	
static func set_unit_weapon(data :UnitData) -> Resource:
	match data.unit_class:
		UnitData.unit_class_vanguard:
			return vanguard_weapons.keys()[rand_range(0, 3)]
		UnitData.unit_class_knight:
			return knight_weapons.keys()[rand_range(0, 3)]
			
	return data.weapon_model
	
static func create_unit_potrait(clas :int) -> AtlasTexture:
	match clas:
		UnitData.unit_class_vanguard:
			var vanguard_potrait = [
				[2,0],[3, 0],[2, 1]
			]
			var pot = vanguard_potrait[rand_range(0, 3)]
			return PotraitGenerator.get_soldier_potrait(pot[0], pot[1])
			
		UnitData.unit_class_knight:
			return PotraitGenerator.get_soldier_potrait(1, 2)
			
		UnitData.unit_class_priest:
			var priest_potrait = [
				[0,1],[0, 3],[2, 2]
			]
			var pot = priest_potrait [rand_range(0, 3)]
			return PotraitGenerator.get_soldier_potrait(pot[0], pot[1])
			
		UnitData.unit_class_hunter, UnitData.unit_class_mage:
			return PotraitGenerator.get_soldier_potrait(0, int(rand_range(0,5)))
			
	return PotraitGenerator.get_soldier_potrait(int(rand_range(0,3)), int(rand_range(0,5)))
