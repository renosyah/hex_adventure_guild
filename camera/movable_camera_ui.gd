extends Control

signal output

var target :Spatial
export var min_zoom :float = 5
export var max_zoom :float = 20

var move_speed := 0.018
var zoom_speed := 0.02

var touches := {}
var is_pinch_zoom := false
var last_pinch_distance := 0.0

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if not _is_point_inside_area(event.position):
			return
		
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			if touches.size() < 2:
				is_pinch_zoom = false

	elif event is InputEventScreenDrag:
		touches[event.index] = event.position
		if touches.size() == 1:
			var delta = event.relative
			var zoom_factor = (target.translation.y / max_zoom)
			var adjusted_move_speed = move_speed * zoom_factor
			target.translate(Vector3(-delta.x * adjusted_move_speed, 0, -delta.y * adjusted_move_speed))
	
		elif touches.size() == 2:
			# Pinch zoom
			var keys = touches.keys()
			var pos1 = touches[keys[0]]
			var pos2 = touches[keys[1]]
			
			var current_distance = pos1.distance_to(pos2)
			
			if !is_pinch_zoom:
				is_pinch_zoom = true
				last_pinch_distance = current_distance
				
			else:
				var delta_distance = current_distance - last_pinch_distance
				target.translate(Vector3(0, -delta_distance * zoom_speed, 0))
				target.translation.y = clamp(target.translation.y, min_zoom, max_zoom)
				last_pinch_distance = current_distance
				
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
