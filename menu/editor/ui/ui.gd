extends Control

signal on_tile_card_grab(pos)
signal on_tile_card_draging(pos)
signal on_tile_card_release(pos,data)
signal on_tile_card_cancel()
signal on_save_map

const tile_card_scene = preload("res://assets/tile_card/tile_card.tscn")

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var tile_options = $SafeArea/VBoxContainer/HBoxContainer2/tile_options
onready var btn_adjacent = $SafeArea/VBoxContainer2/btn_adjacent
onready var btn_view = $SafeArea/VBoxContainer2/btn_view
onready var btn_path = $SafeArea/VBoxContainer2/btn_path
onready var btns = [btn_adjacent, btn_view, btn_path]

var _grabbed_card

func _ready():
	for i in btns:
		i.connect("pressed", self , "_btn_press", [i])
		
	show_tile_options()
	
func show_tile_options():
	var hex = preload("res://scenes/hex_tile/models/hex.png")
	_create_tile_card(hex, null, HexMapData.TileMapDataTypeLand)
	_create_tile_card(hex, null, HexMapData.TileMapDataTypeWater)
	_create_tile_card(hex, null, HexMapData.TileMapDataTypeHill)
	_create_tile_card(hex, preload("res://scenes/object_tile/models/tree_1.png"))
	_create_tile_card(hex, preload("res://scenes/object_tile/models/tree_2.png"), HexMapData.TileMapDataTypeHill)
	#_create_tile_card(hex, preload("res://scenes/object_tile/models/tree_2.png"))
	#_create_tile_card(hex, preload("res://scenes/object_tile/models/tree_3.png"))
	_create_tile_card(hex, preload("res://scenes/object_tile/models/rock_1.png"))
	#_create_tile_card(hex, preload("res://scenes/object_tile/models/rock_2.png"))
	#_create_tile_card(hex, preload("res://scenes/object_tile/models/rock_3.png"))
	
func _create_tile_card(tile_model :Resource, object_model :Resource = null, type :int = 0) -> TileCard:
	var data = _create_tile_option(tile_model,object_model)
	data.type = type
	var card :TileCard = tile_card_scene.instance()
	card.data = data
	card.connect("on_grab", self ,"_on_tile_card_grab")
	card.connect("on_draging", self ,"_on_tile_card_draging")
	card.connect("on_release", self ,"_on_tile_card_release")
	card.connect("on_cancel", self ,"_on_tile_card_cancel")
	tile_options.add_child(card)
	return card
	
func _on_tile_card_grab(card :TileCard, pos:Vector2):
	_grabbed_card = card.get_card_image()
	add_child(_grabbed_card)
	_grabbed_card.rect_global_position = pos
	emit_signal("on_tile_card_grab", pos)
	
func _on_tile_card_draging(card :TileCard, pos:Vector2):
	if is_instance_valid(_grabbed_card):
		_grabbed_card.rect_global_position = pos - _grabbed_card.rect_pivot_offset
		emit_signal("on_tile_card_draging", pos)
	
func _on_tile_card_release(card :TileCard, pos:Vector2):
	_grabbed_card.queue_free()
	
	# duplicate the data
	# so it will not modified other pointer
	var dup:HexMapData.TileMapData = HexMapData.TileMapData.new()
	dup.from_dictionary(card.data.to_dictionary())
	
	
	emit_signal("on_tile_card_release", pos, dup)
	
func _on_tile_card_cancel():
	_grabbed_card.queue_free()
	emit_signal("on_tile_card_cancel")
	
func _create_tile_option(tile_model :Resource, object_model :Resource) -> HexMapData.TileMapData:
	var data :HexMapData.TileMapData = HexMapData.TileMapData.new()
	data.rotation = HexMapUtil.ROTATION_DIRECTIONS[0]
	data.model = tile_model
		
	if object_model:
		var object :HexMapData.ObjectMapData = HexMapData.ObjectMapData.new()
		object.model = object_model
		data.object = object
		
	return data
	
func _on_save_pressed():
	emit_signal("on_save_map")
	
func _btn_press(btn):
	btn_adjacent.pressed = false
	
	for i in btns:
		i.pressed = (i == btn)
