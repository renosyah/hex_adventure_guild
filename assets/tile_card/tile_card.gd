extends MarginContainer
class_name TileCard

signal on_grab
signal on_draging
signal on_release
signal on_cancel

var data :HexMapData.TileMapData

onready var hext_tile = $Viewport/Spatial/hext_tile
onready var object = $Viewport/Spatial/object
onready var texture_rect = $TextureRect
onready var viewport = $Viewport
onready var spatial = $Viewport/Spatial

var _dragging = false
var _drag_offset = Vector2()
var _drag_pos = Vector2()

func _ready():
	texture_rect.texture = viewport.get_texture()
	hext_tile.texture = data.model
	hext_tile.update()
	
	if data.object:
		object.texture = data.object.model
		object.update()
	
	viewport.world.environment = get_viewport().world.environment
	
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





