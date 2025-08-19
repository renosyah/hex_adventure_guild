extends Node
class_name HexMap

signal on_map_ready
signal on_tile_click(tile)

const camera_foward_offset = Vector3.FORWARD * 8
const procedural_tile_limit = Vector2(6, 7)
const tile_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile.tscn")
const tile_sea_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile_sea.tscn")
const tile_hill_scene :PackedScene = preload("res://scenes/hex_tile/hext_tile_hill.tscn")

const object_scene :PackedScene = preload("res://scenes/object_tile/object_tile.tscn")

var _click_position :Vector3

onready var _input_detection = $input_detection
onready var _collision_shape = $Area/CollisionShape
onready var _collision_shape_2 = $StaticBody/CollisionShape2
onready var _tile_holder = $tile_holder
onready var _chunk_management = $chunk_management

onready var _navigation :AStar2D = AStar2D.new()

var _spawned_tiles :Dictionary = {} # { Vector2 : HexTile }
var _hex_map_data :HexMapFileData
var _show_label :bool = false
var _cam_pos :Vector3
var _chunks :Dictionary = {} # {Vector2 : [HexTile] }
var _enable_proceduran_view :bool = false
var _is_editor :bool = false

func generate_from_data(data: HexMapFileData, is_editor:bool = false):
	_clean()
	_is_editor = is_editor
	
	_hex_map_data = data
	
	_enable_proceduran_view = _hex_map_data.map_size > 6
	_collision_shape.scale = Vector3(1,0,1) * _hex_map_data.map_size
	_collision_shape_2.scale = Vector3(1,0,1) * _hex_map_data.map_size
	
	_spawn_tiles()
	_setup_chunk_management()
	_update_navigations()
	
	emit_signal("on_map_ready")
	
func export_data() -> HexMapFileData:
	return _hex_map_data
	
func get_tiles() -> Array:
	return _spawned_tiles.values() # [ HexTile ]
	
func has_tile(id :Vector2) -> bool:
	return _spawned_tiles.has(id)
	
func get_tile(id :Vector2) -> HexTile:
	return _spawned_tiles[id] # HexTile
	
# use this for general purpose
func get_adjacent(from: Vector2, radius: int = 1) -> Array:
	var list :Array = HexMapUtil.get_adjacent_tile(_hex_map_data.tile_ids, from, radius)
	return [from] + list # [ Vector2 ]
	
# use this for view
# if a tile got block, remaining tile in view will not included
# note : view will only cast to adjacent to one direction in straigh
func get_adjacent_view(from: Vector2, radius: int = 1, blocked_ids :Array = []) -> Array:
	var blocked = []
	var allow_see = [
		HexMapData.TileMapDataTypeLand,
		HexMapData.TileMapDataTypeWater,
	]
	for i in _hex_map_data.tiles:
		var x :TileMapData = i
		if blocked_ids.has(x.id):
			continue
			
		if not allow_see.has(x.type) or x.object != null:
			blocked.append(x.id)
			
	blocked_ids.append_array(blocked_ids)
	
	var list :Array = HexMapUtil.get_adjacent_tile_view(_hex_map_data.tile_ids, from, blocked, radius)
	return [from] + list # [ Vector2 ]
	
# use this for navigation
# return a walkable path
func get_astar_adjacent(from: Vector2, radius: int = 1, blocked_ids :Array = []) -> Array:
	var blocked_nav_ids :Array = [] # [ int ]
	for id in blocked_ids:
		blocked_nav_ids.append(_hex_map_data.tile_ids[id])
		
	var list :Array = HexMapUtil.get_astar_adjacent_tile(_hex_map_data.tile_ids[from], _navigation, radius, blocked_nav_ids)
	return [from] + list # [ Vector2 ]
	
func get_adjacent_tile(from: Vector2, radius: int = 1) -> Array:
	return _ids_to_tile_nodes(get_adjacent(from, radius)) # [ HexTile ]
	
func get_adjacent_view_tile(from: Vector2, radius: int = 1, blocked_ids :Array = []) -> Array:
	return _ids_to_tile_nodes(get_adjacent_view(from, radius, blocked_ids)) # [ HexTile ]
	
func get_astar_adjacent_tile(from: Vector2, radius: int = 1, blocked_ids :Array = []) -> Array:
	return _ids_to_tile_nodes(get_astar_adjacent(from, radius, blocked_ids)) # [ HexTile ]
	
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
	enable_nav_tile(at, enable)
	
	if _is_editor:
		var data :NavigationData
		for i in _hex_map_data.navigation_map:
			if i.id == at:
				data = i
				
		if data != null:
			data.enable = enable
		
func update_spawn_tile(data :TileMapData):
	var _spawned_tile :HexTile = _spawned_tiles[data.id]
	if _enable_proceduran_view:
		for key in _chunks:
			var list :Array = _chunks[key]
			if list.has(_spawned_tile):
				list.erase(_spawned_tile)
				break
				
	_tile_holder.remove_child(_spawned_tile)
	_spawned_tile.queue_free()
	
	# spawn new
	var tile :HexTile = _spawn_tile(data)
	tile.visible = true
	
	# update to _hex_map_data
	if _is_editor:
		var pos = 0
		for i in _hex_map_data.tiles:
			var x :TileMapData = i
			if x.id == data.id:
				_hex_map_data.tiles[pos] = data
				return
				
			pos += 1
	
func show_tile_label(v :bool):
	_show_label = v
	for i in _spawned_tiles.values():
		var x :HexTile = i
		x.show_label(_show_label)
	
func update_camera_position(pos :Vector3):
	if not _enable_proceduran_view:
		return
		
	_cam_pos = pos + camera_foward_offset
	_update_camera_location(Vector2(_cam_pos.x, _cam_pos.z) / procedural_tile_limit)
	
func enable_nav_tile(id : Vector2, enable :bool = true):
	var navigation_id: int = _hex_map_data.tile_ids[id]
	if _navigation.has_point(navigation_id):
		_navigation.set_point_disabled(navigation_id, !enable)
		
func is_blocked_nav_tile(id : Vector2):
	var nav_id :int =  _hex_map_data.tile_ids[id]
	if _navigation.has_point(nav_id):
		return _navigation.is_point_disabled(nav_id)
		
	# point not found
	# return is as is it disabled
	return true
	
# param blocked_ids is usefull for 
# seting temporary blocked tile
# like ally unit in the way
func get_navigation(start :Vector2, end :Vector2, blocked_ids :Array = []) -> PoolVector2Array:
	var _blocked_nav_ids :Array = []
	for id in blocked_ids:
		_blocked_nav_ids.append(_hex_map_data.tile_ids[id])
		
	return _get_navigation(_hex_map_data.tile_ids[start],_hex_map_data.tile_ids[end], _blocked_nav_ids) # [ Vector2 ]
	
func _get_navigation(start :int, end :int, _blocked_nav_ids :Array) -> PoolVector2Array:
	var paths :PoolVector2Array = PoolVector2Array([])
	if not _navigation.has_point(start):
		return paths
		
	if not _navigation.has_point(end):
		return paths
		
	var _restored_disabled_point :Array = []
	
	# blocked tile
	for navigation_id in _blocked_nav_ids:
		var has_point :bool = _navigation.has_point(navigation_id)
		var is_already_disabled :bool = _navigation.is_point_disabled(navigation_id)
		if has_point and not is_already_disabled:
			_restored_disabled_point.append(navigation_id)
			_navigation.set_point_disabled(navigation_id, true)
		
	# get path with blocked tiles
	paths = _navigation.get_point_path(start, end)
	
	# open blocked tile
	for navigation_id in _restored_disabled_point:
		_navigation.set_point_disabled(navigation_id, false)
			
	return paths
	
func _setup_chunk_management():
	_chunk_management.start_position = Vector2(_cam_pos.x, _cam_pos.z) / procedural_tile_limit
	_chunk_management.init_starter_chunk()
	
func _update_camera_location(character_location :Vector2):
	_chunk_management.update_camera_location(character_location)
	
func _spawn_tiles():
	for i in _hex_map_data.tiles:
		var data :TileMapData = i
		_spawn_tile(data)
		
func _spawn_tile(data :TileMapData) -> HexTile:
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
	
	if _enable_proceduran_view:
		tile_node.visible = false
	
	_spawned_tiles[data.id] = tile_node
	
	tile_node.show_label(_show_label)
	
	if data.object:
		var object_node :ObjectTile = object_scene.instance()
		object_node.texture = data.object.model
		tile_node.add_child(object_node)
		tile_node.object = object_node
		object_node.set_as_toplevel(true)
		object_node.translation = tile_node.get_object_position()
		object_node.rotation = Vector3.ZERO
		
	if _enable_proceduran_view:
		var pos :Vector3 = data.pos
		var key = _get_tile_chunk(Vector2(pos.x, pos.z), procedural_tile_limit)
		if not _chunks.has(key):
			_chunks[key] = []
			
		_chunks[key].append(tile_node)
	
	tile_node.set_discovered(_is_editor, false)
	
	return tile_node
	
func _get_tile_chunk(pos: Vector2, cell_size: Vector2) -> Vector2:
	var col = int(floor((pos.x + cell_size.x / 2) / cell_size.x))
	var row = int(floor((pos.y + cell_size.y / 2) / cell_size.y))
	return Vector2(col, row)
	
func _update_navigations():
	var navigation_map :Array = _hex_map_data.navigation_map
	_add_point(navigation_map)
	_connect_point(navigation_map)
	_set_obstacle(navigation_map)
	
func _add_point(data :Array):
	for i in data:
		var x :NavigationData = i
		_navigation.add_point(x.navigation_id, x.id)
		
func _connect_point(data :Array):
	for i in data:
		var x :NavigationData = i
		for next_id in x.neighbors:
			_navigation.connect_points(x.navigation_id, next_id, false)
		
func _set_obstacle(data :Array):
	for i in data:
		var x :NavigationData = i
		enable_nav_tile(x.id, x.enable)
		
func _ids_to_tile_nodes(ids :Array) -> Array:
	var datas = []
	for i in ids:
		datas.append(get_tile(i))
	return datas
	
func _clean():
	_chunks.clear()
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

func _on_chunk_management_update_map(_chunks_to_remove :Array, _chunks_to_add:Array):
	for i in _chunks_to_remove:
		var data :ChunkManagement.ChunkData = i
		if _chunks.has(data.position):
			for c in _chunks[data.position]:
				var x :HexTile = c
				x.visible = false
		
	for i in _chunks_to_add:
		var data :ChunkManagement.ChunkData = i
		if _chunks.has(data.position):
			for c in _chunks[data.position]:
				var x :HexTile = c
				x.visible = true



