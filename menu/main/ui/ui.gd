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
	var units = UnitUtils.get_all_unit_resource()
	randomize()
	
	for player_id in [1, 2, 3, 4]:
		var player_data = PlayerBattleData.new()
		player_data.player_id = player_id
		player_data.team = teams[player_id]
		player_data.player_units = []
		
		for i in 6:
			var unit :UnitData = units[rand_range(0, units.size())].duplicate()
			unit.player_id = player_data.player_id
			unit.team = player_data.team
			unit.unit_name = UnitUtils.create_unit_name(unit.unit_class)
			unit.unit_potrait = UnitUtils.create_unit_potrait(unit.unit_class)
			unit.weapon_model = UnitUtils.set_unit_weapon(unit)
			unit.attack_damage = UnitUtils.set_unit_attack_damage(unit)
			player_data.player_units.append(unit)
			
		Global.player_battle_data.append(player_data)
		
	loading.visible = true
	var can_load = Global.load_map("random.map")
	if not can_load:
		Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
		to_battle()
		return
		
	yield(Global, "map_loaded")
	to_battle()
