extends MarginContainer
class_name TileCard

signal on_grab
signal on_draging
signal on_release
signal on_cancel

const tile_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile.tscn")
const tile_sea_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile_sea.tscn")
const object_scene :PackedScene = preload("res://scenes/object_tile/object_tile.tscn")

var data :HexMapData.TileMapData

onready var texture_rect = $TextureRect
onready var viewport = $Viewport
onready var spatial = $Viewport/Spatial

var _dragging = false
var _drag_offset = Vector2()
var _drag_pos = Vector2()

func _ready():
	texture_rect.texture = viewport.get_texture()
	viewport.world.environment = get_viewport().world.environment
	_spawn_tile()
	
func _spawn_tile():
	var tile_node :HexTile
	
	match (data.type):
		HexMapData.TileMapDataTypeLand:
			tile_node = tile_scene.instance()
		HexMapData.TileMapDataTypeWater:
			tile_node = tile_sea_scene.instance()
	
	if data.model:
		tile_node.texture = data.model
		
	tile_node.id = data.id
	tile_node.name = str(tile_node.id)
	spatial.add_child(tile_node)
	tile_node.translation = data.pos
	tile_node.rotation = data.rotation
	
	if data.object:
		var object_node :ObjectTile = object_scene.instance()
		object_node.texture = data.object.model
		tile_node.add_child(object_node)
		object_node.set_as_toplevel(true)
		object_node.rotation = Vector3.ZERO
		
func get_card_image() -> TextureRect:
	return texture_rect.duplicate()

func _on_tile_preview_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			_dragging = true
			_drag_offset = rect_global_position - event.position
			_drag_pos = event.position + _drag_offset
			emit_signal("on_grab", self, _drag_pos)
			texture_rect.visible = false
			
		else:
			_dragging = false
			if not _is_point_inside_area(_drag_pos):
				emit_signal("on_release", self, _drag_pos)
			else:
				emit_signal("on_cancel")
			texture_rect.visible = true
			
	elif event is InputEventScreenDrag:
		if _dragging:
			_drag_pos = event.position + _drag_offset + texture_rect.rect_pivot_offset
			emit_signal("on_draging", self,  _drag_pos)
			
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y





