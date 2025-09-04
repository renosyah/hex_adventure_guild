extends Control

onready var _maps :Array = Utils.load_maps() # [ HexMapFileManifest ]

onready var map_list = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/ScrollContainer/map_list
onready var new_map_dialog = $CanvasLayer/Control/new_map_dialog
onready var dialog_confirm = $CanvasLayer/Control/dialog_confirm

func _ready():
	dialog_confirm.visible = false
	new_map_dialog.visible = false
	show_maps()
	
func show_maps(find :String = ""):
	for i in map_list.get_children():
		map_list.remove_child(i)
		i.queue_free()
		
	for i in _maps:
		var data :HexMapFileManifest = i
		if Utils.contains_substring(data.map_name, find):
			var item = preload("res://menu/editor_menu/ui/item/item.tscn").instance()
			item.data = data
			item.connect("edit", self, "_on_edit_map", [i])
			item.connect("delete", self, "_on_delete_map", [i])
			map_list.add_child(item)

func _on_edit_map(data :HexMapFileManifest):
	load_map(data.map_file_path)

func _on_delete_map(data :HexMapFileManifest):
	dialog_confirm.set_message("Are you sure want delete %s ?" % data.map_name)
	dialog_confirm.visible = true
	var ok = yield(dialog_confirm,"close")
	if ok:
		var path = "user://%s/%s.manifest" % [Global.map_dir, data.map_name]
		SaveLoad.delete_save(data.map_file_path, false)
		SaveLoad.delete_save(data.map_image, false)
		SaveLoad.delete_save(path, false)
		_maps = Utils.load_maps()
		show_maps()
	
func load_map(filename :String):
	var can_load = Global.load_map(filename, false)
	if not can_load:
		return
		
	yield(Global, "map_loaded")
	get_tree().change_scene("res://menu/editor/editor.tscn")
	
func _on_new_map_pressed():
	new_map_dialog.visible = true
	
func _on_search_map_text_changed(new_text):
	show_maps(new_text)

func _on_back_pressed():
	get_tree().change_scene("res://menu/main/main.tscn")

func _on_new_map_dialog_create(map_name, size):
	Global.selected_map_data = HexMapUtil.generate_empty_map(size)
	Global.selected_map_data.map_name = map_name
	get_tree().change_scene("res://menu/editor/editor.tscn")

