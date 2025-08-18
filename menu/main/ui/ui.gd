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
	
	var names = ["Galeno", "Gufa", "Miav", "melvin"]
	var potraits = [[2,3],[2,1],[2,2],[2,4]]
	
	for player_id in [1, 2, 3]:
		var player_data = PlayerBattleData.new()
		player_data.player_id = player_id
		player_data.team = player_id
		player_data.player_units = []
		for i in 4:
			var vanguard = preload("res://scenes/unit/data/units/vanguard.tres").duplicate()
			vanguard.player_id = player_data.player_id
			vanguard.team = player_data.team
			vanguard.unit_name = names[i]
			vanguard.unit_potrait = potraits[i]
			vanguard.hp = 25
			vanguard.max_hp = 25
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
