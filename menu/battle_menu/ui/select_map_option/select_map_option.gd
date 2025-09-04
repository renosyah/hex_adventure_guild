extends Control

signal on_select_map

onready var _maps :Array = Utils.load_maps() # [ HexMapFileManifest ]

onready var map_list = $Control/SafeArea/VBoxContainer/HBoxContainer/ScrollContainer/map_list

func _ready():
		show_maps()
	
func show_maps(find :String = ""):
	for i in map_list.get_children():
		map_list.remove_child(i)
		i.queue_free()
		
	for i in _maps:
		var data :HexMapFileManifest = i
		if Utils.contains_substring(data.map_name, find):
			var item = preload("res://menu/battle_menu/ui/select_map_option/item/item.tscn").instance()
			item.data = data
			item.connect("select", self, "_on_select_map",[data])
			map_list.add_child(item)

func _on_select_map(map :HexMapFileManifest):
	emit_signal("on_select_map", map)
	visible = false

func _on_back_pressed():
	visible = false

func _on_search_map_text_changed(new_text):
	show_maps(new_text)
