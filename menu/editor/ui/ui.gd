extends Control

signal on_tile_card_grab(pos)
signal on_tile_card_draging(pos)
signal on_tile_card_release(pos,data)
signal on_tile_card_cancel()
signal on_change_range(v)
signal on_randomize_map
signal on_save_map

var _range_index = 0
var _ranges = [2, 3, 4]

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var btns = [$SafeArea/VBoxContainer2/btn_adjacent, $SafeArea/VBoxContainer2/btn_view, $SafeArea/VBoxContainer2/btn_path]
onready var object_option = $SafeArea/VBoxContainer/object_option
onready var btn_range = $SafeArea/VBoxContainer2/btn_range

func _ready():
	for i in btns:
		i.connect("pressed", self , "_btn_press", [i])
		
	object_option.index = 0
	object_option.tile_model = preload("res://scenes/hex_tile/models/hex.png")
	object_option.type = HexMapData.TileMapDataTypeLand
	object_option.show_options()
	
func _on_save_pressed():
	emit_signal("on_save_map")
	
func _btn_press(btn):
	for i in btns:
		i.pressed = (i == btn)

func _on_object_option_on_tile_card_cancel():
	emit_signal("on_tile_card_cancel")

func _on_object_option_on_tile_card_draging(pos):
	emit_signal("on_tile_card_draging", pos)

func _on_object_option_on_tile_card_grab(pos):
	emit_signal("on_tile_card_grab", pos)

func _on_object_option_on_tile_card_release(pos, data):
	emit_signal("on_tile_card_release", pos, data)

func _on_btn_tile_land_pressed():
	object_option.index = 0
	object_option.type = HexMapData.TileMapDataTypeLand
	object_option.show_options()
	
func _on_btn_tile_hill_pressed():
	object_option.index = 0
	object_option.type = HexMapData.TileMapDataTypeHill
	object_option.show_options()

func _on_btn_tile_water_pressed():
	object_option.index = 0
	object_option.type = HexMapData.TileMapDataTypeWater
	object_option.show_options()

func _on_btn_tile_more_pressed():
	emit_signal("on_randomize_map")
	
func _on_btn_range_pressed():
	_range_index = _range_index + 1 if _range_index < 2 else 0
	btn_range.text = "x%s" % _ranges[_range_index]
	emit_signal("on_change_range", _ranges[_range_index])

