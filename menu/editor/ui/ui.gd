extends Control

signal on_tile_card_grab(pos)
signal on_tile_card_draging(pos)
signal on_tile_card_release(pos,data)
signal on_tile_card_cancel()
signal on_change_range(v)
signal on_show_tile_label(v)
signal on_randomize_map
signal on_save_map

const checkbox_off = preload("res://assets/icons/checkbox_off.png")
const checkbox_on = preload("res://assets/icons/checkbox_on.png")
const tile_model = preload("res://scenes/hex_tile/models/hex.png")
const object_models = [
	[ null ],
	[ preload("res://scenes/object_tile/models/tree_1.png"), preload("res://scenes/object_tile/models/tree_2.png"), preload("res://scenes/object_tile/models/tree_3.png") ],
	[ preload("res://scenes/object_tile/models/rock_1.png"), preload("res://scenes/object_tile/models/rock_2.png"), preload("res://scenes/object_tile/models/rock_3.png") ]
]

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var object_option = $SafeArea/VBoxContainer/object_option
onready var nav_option = $SafeArea/nav_option
onready var checkbox_tile_label = $SafeArea/VBoxContainer/HBoxContainer2/checkbox_tile_label
onready var loading = $loading
onready var map_name = $SafeArea/VBoxContainer/HBoxContainer/MarginContainer/map_name

var _checkbox :bool = false

func _ready():
	map_name.text = "Name : %s\nSize : %s" % [Global.selected_map_data.map_name, Global.selected_map_data.map_size]
	loading.visible = false
	checkbox_tile_label.button_icon = checkbox_on if _checkbox else checkbox_off
	checkbox_tile_label.update_icon()
	_on_tile_option_on_land_tile()
	
func get_nav_option_buttons():
	return nav_option.btns
	
func _on_save_pressed():
	emit_signal("on_save_map")
	
func _on_object_option_on_tile_card_cancel():
	emit_signal("on_tile_card_cancel")

func _on_object_option_on_tile_card_draging(pos):
	emit_signal("on_tile_card_draging", pos)

func _on_object_option_on_tile_card_grab(pos):
	emit_signal("on_tile_card_grab", pos)

func _on_object_option_on_tile_card_release(pos, data):
	emit_signal("on_tile_card_release", pos, data)
	
func _on_tile_option_on_land_tile():
	object_option.index = 0
	object_option.tile_name = "Land"
	object_option.tile_model = tile_model
	object_option.type = HexMapData.TileMapDataTypeLand
	object_option.objects = object_models
	object_option.show_options()
	
func _on_tile_option_on_hill_tile():
	object_option.index = 0
	object_option.tile_name = "Hill"
	object_option.tile_model = tile_model
	object_option.type = HexMapData.TileMapDataTypeHill
	object_option.objects = object_models
	object_option.show_options()
	
func _on_tile_option_on_water_tile():
	object_option.index = 0
	object_option.tile_name = "Water"
	object_option.tile_model = tile_model
	object_option.type = HexMapData.TileMapDataTypeWater
	object_option.objects = [ [ null ] ] # cannot put anything on water :(
	object_option.show_options()
	
func _on_tile_option_on_randomize():
	emit_signal("on_randomize_map")
	
func _on_nav_option_on_change_range(v):
	emit_signal("on_change_range", v)
	
func _on_checkbox_tile_label_pressed():
	_checkbox = not _checkbox
	checkbox_tile_label.button_icon = checkbox_on if _checkbox else checkbox_off
	checkbox_tile_label.update_icon()
	emit_signal("on_show_tile_label", _checkbox)
