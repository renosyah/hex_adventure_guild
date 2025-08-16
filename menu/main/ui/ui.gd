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
	for i in 4:
		var vanguard = preload("res://scenes/unit/data/units/vanguard.tres").duplicate()
		vanguard.player_id = Global.player_id
		vanguard.team = Global.team
		vanguard.unit_name = RandomNameGenerator.generate()
		vanguard.unit_potrait = [int(rand_range(0, 8)),int(rand_range(0, 11))]
		Global.player_units.append(vanguard)
	
	loading.visible = true
	var can_load = Global.load_map("random.map")
	if not can_load:
		Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
		to_battle()
		return
		
	yield(Global, "map_loaded")
	to_battle()
