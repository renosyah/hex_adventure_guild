extends Control
onready var loading = $loading

func _ready():
	loading.visible = false
	
func to_battle():
	loading.visible = false
	get_tree().change_scene("res://menu/gameplay_battle/gameplay_battle.tscn")
	
func to_editor():
	loading.visible = false
	get_tree().change_scene("res://menu/editor/editor.tscn")
	
func _on_editor_pressed():
	loading.visible = true
	var can_load = Global.load_map("random.map")
	if not can_load:
		Global.selected_map_data = HexMapUtil.generate_empty_map()
		to_editor()
		return
		
	yield(Global, "map_loaded")
	to_editor()

func _on_battle_pressed():
	Global.player_battle_data.clear()
	
	var teams = {1:1,2:1,3:2,4:2}
	var vanguard_weapons = {
		preload("res://scenes/unit/vanguard/glaive.png") : 24,
		preload("res://scenes/unit/vanguard/pike.png") : 18,
		preload("res://scenes/unit/vanguard/spear.png") : 14
	}
	var knight_weapons = {
		preload("res://scenes/unit/knight/axe.png") : 18,
		preload("res://scenes/unit/knight/sword.png") : 24,
		preload("res://scenes/unit/knight/war_hammer.png") : 28
	}
	var vanguard_potrait = [
		[2,0],[3, 0],[2, 1]
	]
	for player_id in [1, 2, 3, 4]:
		var player_data = PlayerBattleData.new()
		player_data.player_id = player_id
		player_data.team = teams[player_id]
		player_data.player_units = []
		
		var peasant = preload("res://scenes/unit/data/units/peasant.tres").duplicate()
		peasant.player_id = player_data.player_id
		peasant.team = player_data.team
		peasant.unit_name = "%s (%s)" %[RandomNameGenerator.generate_name(), "Peasant"]
		peasant.unit_potrait = [2, 3]
		player_data.player_units.append(peasant)
		
		var knight_weapon = knight_weapons.keys()[rand_range(0, 3)]
		
		var knight = preload("res://scenes/unit/data/units/knight.tres").duplicate()
		knight.player_id = player_data.player_id
		knight.team = player_data.team
		knight.unit_name = "Sir %s (%s)" %[RandomNameGenerator.generate_name(), "Knight"]
		knight.unit_potrait = [1, 2]
		knight.attack_damage = knight_weapons[knight_weapon]
		knight.weapon_model = knight_weapon
		player_data.player_units.append(knight)
		
		for i in 2:
			var weapon = vanguard_weapons.keys()[rand_range(0, 3)]
			var unit_potrait = vanguard_potrait[rand_range(0, 3)]
			var vanguard = preload("res://scenes/unit/data/units/vanguard.tres").duplicate()
			vanguard.player_id = player_data.player_id
			vanguard.team = player_data.team
			vanguard.unit_name = "%s (%s)" %[RandomNameGenerator.generate_name(), "Vanguard"]
			vanguard.unit_potrait = unit_potrait
			vanguard.attack_damage = vanguard_weapons[weapon]
			vanguard.weapon_model = weapon
			player_data.player_units.append(vanguard)
			
		for i in 2:
			var hunter = preload("res://scenes/unit/data/units/hunter.tres").duplicate()
			hunter.player_id = player_data.player_id
			hunter.team = player_data.team
			hunter.unit_name = "%s (%s)" %[RandomNameGenerator.generate_name(), "Hunter"]
			hunter.unit_potrait = [0, int(rand_range(0,5))]
			player_data.player_units.append(hunter)
			
		Global.player_battle_data.append(player_data)
		
	loading.visible = true
	var can_load = Global.load_map("random.map")
	if not can_load:
		Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
		to_battle()
		return
		
	yield(Global, "map_loaded")
	to_battle()
