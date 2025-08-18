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
	var weapons = {
		preload("res://scenes/unit/vanguard/glaive.png") : 24,
		preload("res://scenes/unit/vanguard/pike.png") : 18,
		preload("res://scenes/unit/vanguard/spear.png") : 14
	}
	
	for player_id in [1, 2, 3, 4]:
		var player_data = PlayerBattleData.new()
		player_data.player_id = player_id
		player_data.team = teams[player_id]
		player_data.player_units = []
		for i in 6:
			var weapon = weapons.keys()[rand_range(0, 3)]
			var vanguard = preload("res://scenes/unit/data/units/vanguard.tres").duplicate()
			vanguard.player_id = player_data.player_id
			vanguard.team = player_data.team
			vanguard.unit_name = RandomNameGenerator.generate()
			vanguard.unit_potrait = [int(rand_range(0,8)), int(rand_range(0,10))]
			vanguard.hp = 25
			vanguard.max_hp = 25
			vanguard.attack_damage = weapons[weapon]
			vanguard.weapon_model = weapon
			player_data.player_units.append(vanguard)
			
		Global.player_battle_data.append(player_data)
		
	loading.visible = true
	var can_load = Global.load_map("random.map")
	if not can_load:
		Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
		to_battle()
		return
		
	yield(Global, "map_loaded")
	to_battle()
