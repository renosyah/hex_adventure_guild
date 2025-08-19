extends Node
class_name HexMapUtil

static func generate_randomize_map(_seed :int, radius: int = 6) -> HexMapFileData:
	var blocked = []
	var data = generate_empty_map(radius)
	var noise = OpenSimplexNoise.new()
	var rng = RandomNumberGenerator.new()
	rng.seed = _seed
	
	noise.seed = _seed
	noise.octaves = 3
	noise.period = 12.0
	noise.persistence = 0.856
	noise.lacunarity = 1.745
	
	var objs = [
		preload("res://scenes/object_tile/models/tree_1.png"),
		preload("res://scenes/object_tile/models/tree_2.png"),
		preload("res://scenes/object_tile/models/tree_3.png"),
		preload("res://scenes/object_tile/models/rock_1.png"),
		preload("res://scenes/object_tile/models/rock_2.png"),
		preload("res://scenes/object_tile/models/rock_3.png")
	]
	
	var points = get_tile_spawn_point(data.tile_ids, Vector2.ZERO, data.map_size)
	var spawn_points = []
	for i in points:
		var ids :Array = i
		spawn_points.append_array(ids)
		
	for i in data.tiles:
		var x :TileMapData = i
		x.model = preload("res://scenes/hex_tile/models/hex.png")
		
		# reserve for spawn point
		if spawn_points.has(x.id):
			x.type = HexMapData.TileMapDataTypeLand
			continue
			
		var value = 2 * abs(noise.get_noise_2dv(x.id))
		if value > 0.8:
			x.type = HexMapData.TileMapDataTypeHill
			blocked.append(x.id)
			
		elif value > 0.1 and value < 0.8:
			x.type = HexMapData.TileMapDataTypeLand
			
		else:
			x.type = HexMapData.TileMapDataTypeWater
			blocked.append(x.id)
			
			
		if x.type == HexMapData.TileMapDataTypeLand or x.type == HexMapData.TileMapDataTypeHill:
			if rng.randf() < 0.4:
				x.object = ObjectMapData.new()
				x.object.model = objs[rng.randf_range(0, objs.size() - 1)]
				blocked.append(x.id)
			
	for i in data.navigation_map:
		var x :NavigationData = i
		x.enable = not blocked.has(x.id)
		
	return data
	
static func generate_empty_map(radius: int = 6) -> HexMapFileData:
	var generated_tiles :Array = create_adjacent_tiles(Vector2.ZERO, radius)
	var tile_ids :Dictionary = {}
	var index = 1
	for i in generated_tiles:
		tile_ids[i] = index
		index += 1
		
	var tiles :Array = []
	for key in tile_ids.keys():
		var id :Vector2 = key
		var is_odd :bool = int(id.y) % 2 != 0
		var x_offset:float = 0.5 if is_odd else 0
		
		var data :TileMapData = TileMapData.new()
		data.id = id
		data.pos = Vector3(id.x + x_offset, 0, id.y * 0.85) * 2
		data.rotation = ROTATION_DIRECTIONS[0]
		
		tiles.append(data)
		
	var navigation_map = []
	for key in tile_ids.keys():
		var data :NavigationData = NavigationData.new()
		data.id = key
		data.navigation_id = tile_ids[key]
		data.enable = false
		
		var neighbors = []
		var adjacents = get_adjacent_tile(tile_ids, key, 1)
		for i in adjacents:
			neighbors.append(tile_ids[i])
		
		data.neighbors = neighbors
		navigation_map.append(data)
	
	var n = HexMapFileData.new()
	n.map_name = "random"
	n.map_size = radius
	n.tile_ids = tile_ids
	n.tiles = tiles
	n.navigation_map = navigation_map
	return n
	
const ROTATION_DIRECTIONS = [
	Vector3(0,deg2rad(60),0),
	Vector3(0,deg2rad(-60),0),
	Vector3(0,deg2rad(120),0),
	Vector3(0,deg2rad(-120),0),
]

const ODD_TILE = [
	Vector2.RIGHT,            # (1, 0)
	Vector2.UP + Vector2.RIGHT, # (1, -1)
	Vector2.UP,               # (0, -1)
	Vector2.LEFT,             # (-1, 0)
	Vector2.DOWN,             # (0, 1)
	Vector2.ONE               # (1, 1)
]

const EVEN_TILE = [
	Vector2.RIGHT,            # (1, 0)
	Vector2.UP,               # (0, -1)
	Vector2.UP + Vector2.LEFT,# (-1, -1)
	Vector2.LEFT,             # (-1, 0)
	Vector2.DOWN + Vector2.LEFT,# (-1, 1)
	Vector2.DOWN              # (0, 1)
]

static func get_directions(tile: Vector2) -> Array:
	if int(tile.y) % 2 != 0:
		return ODD_TILE
	return EVEN_TILE
	
# tiles :Dictionary = {Vector2: any }
static func get_adjacent_tile(tiles :Dictionary, from: Vector2, radius: int = 1) -> Array:
	var visited := {}
	var frontier := [from]
	visited[from] = true

	for step in range(radius):
		var next_frontier := []
		for current in frontier:
			var directions = get_directions(current)
			for dir in directions:
				var neighbor = current + dir
				if tiles.has(neighbor) and not visited.has(neighbor):
					visited[neighbor] = true
					next_frontier.append(neighbor)
		frontier = next_frontier
		
	visited.erase(from)
	var datas :Array = visited.keys().duplicate()
	
	visited.clear()
	frontier.clear()
	
	return datas # [Vector2]
	
# tiles :Dictionary = {Vector2: any }
static func get_adjacent_tile_common(from: Vector2, radius: int = 1) -> Array:
	var visited := {}
	var frontier := [from]
	visited[from] = true

	for step in range(radius):
		var next_frontier := []
		for current in frontier:
			var directions = get_directions(current)
			for dir in directions:
				var neighbor = current + dir
				if not visited.has(neighbor):
					visited[neighbor] = true
					next_frontier.append(neighbor)
		frontier = next_frontier
		
	visited.erase(from)
	var datas :Array = visited.keys().duplicate()
	
	visited.clear()
	frontier.clear()
	
	return datas # [Vector2]
	
static func get_tile_spawn_point(tiles: Dictionary, from: Vector2, size: int = 1, spawn_radius: int = 2) -> Array:
	var results: Array = []
	var resDir :Dictionary = {} # { Vector2 : Vector2 }

	for base_dir in get_directions(from):
		var current = from
		for step in range(size):
			var dir = base_dir
			if step > 0:
				dir = get_directions(current)[get_directions(from).find(base_dir)]
			current += dir
			
			if not tiles.has(current):
				break
				
			if current != from and step == (size - 1):
				resDir[base_dir] = current
				
			
	for key in resDir.keys():
		var id :Vector2 = resDir[key] # Vector2
		results.append(get_adjacent_tile(tiles, id, spawn_radius) + [id])
		
	return results # [ [ Vector2 ],[ ... ] ]
	
static func get_adjacent_tile_view(tiles: Dictionary, from: Vector2, blocked: Array, radius: int = 1) -> Array:
	var results: Array = []

	for base_dir in get_directions(from):
		var current = from
		for step in range(radius):
			var dir = base_dir
			if step > 0:
				dir = get_directions(current)[get_directions(from).find(base_dir)]
			current += dir
			
			if not tiles.has(current):
				break
				
			if current in blocked:
				results.append(current)
				break
				
			results.append(current)
			
	return results

static func get_astar_adjacent_tile(navigation_id: int, navigation :AStar2D, radius: int = 1, blocked_nav_ids :Array = []) -> Array:
	var visited := {}
	var result := []
	var queue := [navigation_id]
	visited[navigation_id] = 0

	while not queue.empty():
		var current_id = queue.pop_front()
		var current_depth = visited[current_id]

		if current_depth >= radius:
			continue

		for neighbor_id in navigation.get_point_connections(current_id):
			if neighbor_id in visited:
				continue
				
			if navigation.is_point_disabled(neighbor_id):
				continue
				
			if blocked_nav_ids.has(neighbor_id):
				continue
				
			visited[neighbor_id] = current_depth + 1
			queue.append(neighbor_id)
			result.append(navigation.get_point_position(neighbor_id))
			
	visited.clear()
	queue.clear()
	
	return result # [Vector2]
	
	
static func create_adjacent_tiles(from: Vector2, radius: int = 1) -> Array:
	var visited := {}
	var frontier := [from]
	visited[from] = true
	
	for step in range(radius):
		var next_frontier := []
		for current in frontier:
			var directions = get_directions(current)
			for dir in directions:
				var neighbor = current + dir
				if not visited.has(neighbor):
					visited[neighbor] = true
					next_frontier.append(neighbor)
		frontier = next_frontier
		
	visited.erase(from)
	var datas :Array = [from] + visited.keys().duplicate()
	
	visited.clear()
	frontier.clear()
	
	return datas # [Vector2]
