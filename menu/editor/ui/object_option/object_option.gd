extends Control

signal on_tile_card_grab(pos)
signal on_tile_card_draging(pos)
signal on_tile_card_release(pos,data)
signal on_tile_card_cancel()

const tile_card_scene = preload("res://assets/tile_card/tile_card.tscn")

export var tile_model :Resource
export var type :int = 0

onready var label = $HBoxContainer/TextureRect/Label
onready var prev_object = $VBoxContainer/HBoxContainer2/prev_object
onready var next_object = $VBoxContainer/HBoxContainer2/next_object
onready var tile_options = $VBoxContainer/HBoxContainer2/tile_options
onready var objects :Array = [
	[
		null,
	],
	[
		preload("res://scenes/object_tile/models/tree_1.png"),
		preload("res://scenes/object_tile/models/tree_2.png"),
		preload("res://scenes/object_tile/models/tree_3.png")
	],
	[
		preload("res://scenes/object_tile/models/rock_1.png"),
		preload("res://scenes/object_tile/models/rock_2.png"),
		preload("res://scenes/object_tile/models/rock_3.png")
	]
]

var _grabbed_card
var index :int = 0

func show_options():
	_clean()
	
	if type == HexMapData.TileMapDataTypeWater:
		prev_object.visible = false
		next_object.visible = false
		
		_create_tile_card(tile_model, null, type)
		
	else:
		prev_object.visible = true
		next_object.visible = true
		
		for i in objects[index]:
			_create_tile_card(tile_model, i, type)
			
	prev_object.modulate.a = 1 if index > 0 else 0
	next_object.modulate.a = 1 if index < objects.size() - 1 else 0
	_set_label()
	
func _set_label():
	match (type):
		HexMapData.TileMapDataTypeLand:
			label.text = "Land\n"
		HexMapData.TileMapDataTypeWater:
			label.text = "Water\n"
		HexMapData.TileMapDataTypeHill:
			label.text = "Hill\n"
	
	
func _clean():
	for i in tile_options.get_children():
		tile_options.remove_child(i)
		i.queue_free()

func _create_tile_card(tile_model :Resource, object_model :Resource = null, type :int = 0) -> TileCard:
	var data = _create_tile_option(tile_model, object_model, type )
	
	var card :TileCard = tile_card_scene.instance()
	card.data = data
	card.connect("on_grab", self ,"_on_tile_card_grab")
	card.connect("on_draging", self ,"_on_tile_card_draging")
	card.connect("on_release", self ,"_on_tile_card_release")
	card.connect("on_cancel", self ,"_on_tile_card_cancel")
	tile_options.add_child(card)
	return card
	
func _create_tile_option(tile_model :Resource, object_model :Resource, type :int = 0) -> HexMapData.TileMapData:
	var data :HexMapData.TileMapData = HexMapData.TileMapData.new()
	data.rotation = HexMapUtil.ROTATION_DIRECTIONS[0]
	data.model = tile_model
	data.type = type
	
	# object is not null and tile type is not water
	if object_model and data.type != HexMapData.TileMapDataTypeWater:
		var object :HexMapData.ObjectMapData = HexMapData.ObjectMapData.new()
		object.model = object_model
		data.object = object
		
	return data
	
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
	
func _on_prev_object_pressed():
	index = clamp(index - 1, 0, objects.size() - 1)
	show_options()
	
func _on_next_object_pressed():
	index = clamp(index + 1, 0, objects.size() - 1)
	show_options()
	
