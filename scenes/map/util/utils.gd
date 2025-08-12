extends Node
class_name HexMapUtil

static func generate_empty_map(radius: int = 3) -> HexMapData.HexMapFileData:
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
		
		var data :HexMapData.TileMapData = HexMapData.TileMapData.new()
		data.id = id
		data.pos = Vector3(id.x + x_offset, 0, id.y * 0.85) * 2
		data.rotation = ROTATION_DIRECTIONS[0]
		
		tiles.append(data)
		
	var navigation_map = []
	for key in tile_ids.keys():
		var data :HexMapData.NavigationData = HexMapData.NavigationData.new()
		data.id = key
		data.navigation_id = tile_ids[key]
		data.enable = false
		
		var neighbors = []
		var adjacents = get_adjacent_tile(tile_ids, key, 1)
		for i in adjacents:
			neighbors.append(tile_ids[i])
		
		data.neighbors = neighbors
		navigation_map.append(data)
	
	var n = HexMapData.HexMapFileData.new()
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
				break
				
			results.append(current)
			
	return results

static func get_astar_adjacent_tile(navigation_id: int, navigation :AStar2D, radius: int = 1) -> Array:
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
