extends Node

signal on_tile_click(tile)

const tile_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile.tscn")
const tile_sea_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile_sea.tscn")
const tile_hill_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile_hill.tscn")

const object_scene :PackedScene = preload("res://scenes/object_tile/object_tile.tscn")

var _click_position :Vector3

onready var _input_detection = $input_detection
onready var _collision_shape = $Area/CollisionShape
onready var _collision_shape_2 = $StaticBody/CollisionShape2
onready var _tile_holder = $tile_holder

onready var _navigation :AStar2D = AStar2D.new()

var _spawned_tiles :Dictionary = {} # { Vector2 : HexTile }
var _hex_map_data :HexMapData.HexMapFileData
var _show_label :bool = false

func generate_from_data(data: HexMapData.HexMapFileData):
	_clean()
	_hex_map_data = data
	
	_collision_shape.scale = Vector3(1,0,1) * _hex_map_data.map_size
	_collision_shape_2.scale = Vector3(1,0,1) * _hex_map_data.map_size
	
	_spawn_tiles()
	_update_navigations()
	
func export_data() -> HexMapData.HexMapFileData:
	return _hex_map_data
	
func get_tiles() -> Array:
	return _spawned_tiles.values() # [ Vector2 ]
	
func get_tile(id :Vector2) -> Array:
	return _spawned_tiles[id] # HexTile
	
# use this for general purpose
func get_adjacent(from: Vector2, radius: int = 1) -> Array:
	var list :Array = HexMapUtil.get_adjacent_tile(_hex_map_data.tile_ids, from, radius)
	return [from] + list # [ Vector2 ]
	
# use this for view
# if a tile got block, remaining tile in view will not included
# note : view will only cast to adjacent to one direction in straigh
func get_adjacent_view(from: Vector2, radius: int = 1) -> Array:
	var blocked = []
	var allow_see = [
		HexMapData.TileMapDataTypeLand,
		HexMapData.TileMapDataTypeWater,
	]
	for i in _hex_map_data.tiles:
		var x :HexMapData.TileMapData = i
		
		if not allow_see.has(x.type) or x.object != null:
			blocked.append(x.id)
			
	var list :Array = HexMapUtil.get_adjacent_tile_view(_hex_map_data.tile_ids, from, blocked, radius)
	return [from] + list # [ Vector2 ]
	
# use this for navigation
# return a walkable path
func get_astar_adjacent(from: Vector2, radius: int = 1) -> Array:
	var list :Array = HexMapUtil.get_astar_adjacent_tile(_hex_map_data.tile_ids[from], _navigation, radius)
	return [from] + list # [ Vector2 ]
	
func get_adjacent_tile(from: Vector2, radius: int = 1) -> Array:
	return _ids_to_tile_nodes(get_adjacent(from, radius)) # [ HexTile ]
	
func get_adjacent_view_tile(from: Vector2, radius: int = 1) -> Array:
	return _ids_to_tile_nodes(get_adjacent_view(from, radius)) # [ HexTile ]
	
func get_astar_adjacent_tile(from: Vector2, radius: int = 1) -> Array:
	return _ids_to_tile_nodes(get_astar_adjacent(from, radius)) # [ HexTile ]
	
func get_closes_tile(from :Vector3) -> HexTile:
	var current = _tile_holder.get_child(0)
	for i in _tile_holder.get_children():
		if i == current:
			continue
			
		var dist_1 = current.translation.distance_squared_to(from)
		var dist_2 = i.translation.distance_squared_to(from)
		if dist_2 < dist_1:
			current = i
			
	return current # HexTile
	
func update_navigation_tile(at :Vector2, enable :bool):
	var data :HexMapData.NavigationData
	for i in _hex_map_data.navigation_map:
		if i.id == at:
			data = i
			
	if data == null:
		return
		
	data.enable = enable
	
	if _navigation.has_point(data.navigation_id):
		_navigation.set_point_disabled(data.navigation_id, !data.enable)
	
func update_spawn_tile(data :HexMapData.TileMapData):
	var _spawned_tile :HexTile = _spawned_tiles[data.id]
	_tile_holder.remove_child(_spawned_tile)
	_spawned_tile.queue_free()
	
	_spawn_tile(data)
	
	var pos = 0
	for i in _hex_map_data.tiles:
		var x :HexMapData.TileMapData = i
		if x.id == data.id:
			_hex_map_data.tiles[pos] = data
			return
			
		pos += 1
	
func show_tile_label(v :bool):
	_show_label = v
	for i in _spawned_tiles.values():
		var x :HexTile = i
		x.show_label(_show_label)
	
func _spawn_tiles():
	for i in _hex_map_data.tiles:
		var data :HexMapData.TileMapData = i
		_spawn_tile(data)
		
func _spawn_tile(data :HexMapData.TileMapData):
	var tile_node :HexTile
	
	match (data.type):
		HexMapData.TileMapDataTypeLand:
			tile_node = tile_scene.instance()
		HexMapData.TileMapDataTypeWater:
			tile_node = tile_sea_scene.instance()
		HexMapData.TileMapDataTypeHill:
			tile_node = tile_hill_scene.instance()
			
	if tile_node == null:
		 tile_node = tile_scene.instance()
		
	if data.model:
		tile_node.texture = data.model
		
	tile_node.id = data.id
	tile_node.name = str(tile_node.id)
	_tile_holder.add_child(tile_node)
	tile_node.translation = data.pos
	tile_node.rotation = data.rotation
	_spawned_tiles[data.id] = tile_node
	
	tile_node.show_label(_show_label)
	
	if data.object:
		var object_node :ObjectTile = object_scene.instance()
		object_node.texture = data.object.model
		tile_node.add_child(object_node)
		object_node.set_as_toplevel(true)
		object_node.translation = tile_node.get_object_position()
		object_node.rotation = Vector3.ZERO
		

func _update_navigations():
	_add_point(_navigation, _hex_map_data.navigation_map)
	_connect_point(_navigation, _hex_map_data.navigation_map)
	_set_obstacle(_navigation, _hex_map_data.navigation_map)
	
func _add_point(aStar2D :AStar2D, data :Array):
	for i in data:
		var x :HexMapData.NavigationData = i
		aStar2D.add_point(x.navigation_id, x.id)
		
func _connect_point(aStar2D :AStar2D, data :Array):
	for i in data:
		var x :HexMapData.NavigationData = i
		for next_id in x.neighbors:
			aStar2D.connect_points(x.navigation_id, next_id, false)
		
func _set_obstacle(aStar2D :AStar2D, data :Array):
	for i in data:
		var x :HexMapData.NavigationData = i
		if aStar2D.has_point(x.navigation_id):
			aStar2D.set_point_disabled(x.navigation_id, !x.enable)
			
func _ids_to_tile_nodes(ids :Array) -> Array:
	var datas = []
	for i in ids:
		datas.append(get_tile(i))
	return datas
	
func _clean():
	_navigation.clear()
	_spawned_tiles.clear()
	_remove_child(_tile_holder)
	
func _remove_child(node :Node):
	for i in node.get_children():
		var x :Node = i
		node.remove_child(x)
		x.queue_free()
	
func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		var tile : HexTile = get_closes_tile(_click_position)
		emit_signal("on_tile_click", tile)

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	_click_position = position
	_input_detection.check_input(event)
