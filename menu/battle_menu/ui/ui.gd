extends Control

const player_unit_item_scene = preload("res://menu/battle_menu/ui/player_unit_item/player_unit_item.tscn")

onready var map_image = $CanvasLayer/Control/SafeArea/VBoxContainer/map/VBoxContainer/HBoxContainer/map_image
onready var map_name = $CanvasLayer/Control/SafeArea/VBoxContainer/map/VBoxContainer/HBoxContainer/VBoxContainer/map_name
onready var map_size = $CanvasLayer/Control/SafeArea/VBoxContainer/map/VBoxContainer/HBoxContainer/VBoxContainer/map_size

onready var team_list = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer3/ScrollContainer/VBoxContainer/team_list
onready var battle_button = $CanvasLayer/Control/SafeArea/VBoxContainer/battle
onready var add_player = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer3/ScrollContainer/VBoxContainer/add_player

var selected_map :HexMapFileManifest

func  _ready():
	refresh()
	
func refresh():
	display_map()
	display_teams()
	battle_button.disabled = Global.player_battle_data.empty() or selected_map == null
	add_player.visible = Global.player_battle_data.size() < 6
	
func add_player(player_id :int, team :int):
	var units = UnitUtils.get_unit_datas()
	
	var player_data = PlayerBattleData.new()
	player_data.player_id = player_id
	player_data.team = team
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
	refresh()
	
func display_teams():
	for i in team_list.get_children():
		team_list.remove_child(i)
		i.queue_free()
		
	for i in Global.player_battle_data:
		var data :PlayerBattleData = i
		var player_unit = player_unit_item_scene.instance()
		player_unit.data = data
		player_unit.connect("change_team", self ,"_on_change_team_player_unit", [player_unit, data])
		player_unit.connect("edit", self, "_on_edit_player_unit", [player_unit, data])
		team_list.add_child(player_unit)
		
func display_map():
	var _maps :Array = Utils.load_maps()
	if _maps.empty():
		return
		
	selected_map = _maps[0]
	
	var img = Image.new()
	img.load(selected_map.map_image)
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	map_image.texture = tex
	map_name.text = selected_map.map_name
	map_size.text = "Map size : %s" % selected_map.map_size
	
func load_map(filename :String):
	var can_load = Global.load_map(filename, false)
	if can_load:
		yield(Global, "map_loaded")
		get_tree().change_scene("res://menu/gameplay_battle/gameplay_battle.tscn")

func _on_back_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")
	
func _on_change_team_player_unit(player_unit, data :PlayerBattleData):
	data.team = (data.team + 1) if data.team < Global.player_battle_data.size() else 1
	
	for i in data.player_units:
		var unit :UnitData = i
		unit.team = data.team
		
	if data.player_id == Global.current_player_id:
		Global.current_player_team = data.team
		
	player_unit.update_display()
	
func _on_add_player_pressed():
	var id = Global.player_battle_data.size() + 1
	var team = id
	add_player(id, team)
	
func _on_edit_player_unit(player_unit, data :PlayerBattleData):
	pass # Replace with function body.
	
func _on_change_map_pressed():
	pass # Replace with function body.
	
func _on_battle_pressed():
	load_map(selected_map.map_file_path)








