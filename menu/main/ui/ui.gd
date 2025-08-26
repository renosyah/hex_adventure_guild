extends Control
onready var loading = $loading

func _ready():
	loading.visible = false
	
func to_battle():
	loading.visible = false
	get_tree().change_scene("res://menu/gameplay_battle/gameplay_battle.tscn")
	
func _on_editor_pressed():
	get_tree().change_scene("res://menu/editor_menu/editor_menu.tscn")

func _on_battle_pressed():
	Global.player_battle_data.clear()
	
	var teams = {1:1,2:2,3:2,4:2}
	var units = UnitUtils.get_unit_datas()
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
			unit.attack_damages = UnitUtils.set_unit_attack_damages(unit)
			player_data.player_units.append(unit)
			
		Global.player_battle_data.append(player_data)
		
	loading.visible = true
	
	var _maps :Array = Utils.load_maps()
	if not _maps.empty():
		_load_map(_maps[0].map_file_path)
		return
		
	Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
	to_battle()
	
func _load_map(filename :String):
	var can_load = Global.load_map(filename, false)
	if can_load:
		yield(Global, "map_loaded")
		to_battle()
