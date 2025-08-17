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
	Global.player_units.clear()
	
	var names = ["Galeno", "GuFa", "Miav", "melvin"]
	var potraits = [[2,3],[2,1],[2,2],[2,4]]
	
	for i in 4:
		var vanguard = preload("res://scenes/unit/data/units/vanguard.tres").duplicate()
		vanguard.player_id = Global.player_id
		vanguard.team = Global.team
		vanguard.unit_name = names[i]
		vanguard.unit_potrait = potraits[i]
		vanguard.hp = 25
		vanguard.max_hp = 25
		Global.player_units.append(vanguard)
	
	loading.visible = true
	var can_load = Global.load_map("random.map")
	if not can_load:
		Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
		to_battle()
		return
		
	yield(Global, "map_loaded")
	to_battle()
