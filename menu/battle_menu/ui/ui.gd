extends Control

const player_unit_item_scene = preload("res://menu/battle_menu/ui/player_unit_item/player_unit_item.tscn")

onready var map_image = $CanvasLayer/Control/SafeArea/VBoxContainer/map/VBoxContainer/HBoxContainer/map_image
onready var map_name = $CanvasLayer/Control/SafeArea/VBoxContainer/map/VBoxContainer/HBoxContainer/VBoxContainer/map_name
onready var map_size = $CanvasLayer/Control/SafeArea/VBoxContainer/map/VBoxContainer/HBoxContainer/VBoxContainer/map_size

onready var team_list = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer3/ScrollContainer/VBoxContainer/team_list
onready var battle_button = $CanvasLayer/Control/SafeArea/VBoxContainer/battle
onready var add_player = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer3/ScrollContainer/VBoxContainer/add_player
onready var select_map_option = $CanvasLayer/Control/select_map_option

onready var units = UnitUtils.get_unit_datas()
var selected_map :HexMapFileManifest

func  _ready():
	var _maps :Array = Utils.load_maps()
	if not _maps.empty():
		selected_map = _maps[0]
		
	select_map_option.visible = false
	add_player(1, 1)
	refresh()
	
func refresh():
	display_map()
	display_teams()
	battle_button.disabled = not can_battle()
	add_player.visible = Global.player_battle_data.size() < 6
	
func can_battle() -> bool:
	var team :Dictionary = {}
	for i in Global.player_battle_data:
		var player_data :PlayerBattleData = i
		team[player_data.team] = true
		
	var conditions = [
		selected_map == null,
		team.keys().size() <= 1
	]
	return not conditions.has(true)
	
func add_player(player_id :int, team :int):
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
	if selected_map == null:
		return
	
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
		
	refresh()
	
func _on_add_player_pressed():
	var index = Global.player_battle_data.size() + 1
	add_player(index, index)
	refresh()
	
func _on_edit_player_unit(player_unit, data :PlayerBattleData):
	pass # Replace with function body.
	
func _on_change_map_pressed():
	select_map_option.visible = true

func _on_select_map_option_on_select_map(data :HexMapFileManifest):
	selected_map = data
	display_map()
	
func _on_battle_pressed():
	load_map(selected_map.map_file_path)










