extends Control

onready var _maps :Array = Utils.load_maps() # [ HexMapFileManifest ]

onready var map_list = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/ScrollContainer/map_list

func _ready():
	show_maps()
	
func show_maps(find :String = ""):
	for i in map_list.get_children():
		map_list.remove_child(i)
		i.queue_free()
		
	for i in _maps:
		var data :HexMapFileManifest = i
		if Utils.contains_substring(data.map_name, find):
			var item = preload("res://menu/editor_menu/item/item.tscn").instance()
			item.data = data
			item.connect("edit", self, "_on_edit_map", [i])
			map_list.add_child(item)

func _on_edit_map(data :HexMapFileManifest):
	load_map(data.map_file_path)

func load_map(filename :String):
	var can_load = Global.load_map(filename, false)
	if not can_load:
		return
		
	yield(Global, "map_loaded")
	get_tree().change_scene("res://menu/editor/editor.tscn")
	
	
func _on_new_map_pressed():
	Global.selected_map_data = HexMapUtil.generate_randomize_map(rand_range(-1000, 1000))
	Global.selected_map_data.map_name = RandomNameGenerator.generate_name()
	get_tree().change_scene("res://menu/editor/editor.tscn")

func _on_search_map_text_changed(new_text):
	show_maps(new_text)

func _on_back_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")
