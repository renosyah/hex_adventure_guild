extends Node
class_name Utils

static func get_all_resources(path: String, extensions := ["tres", "res", "tscn", "scn", "obj"]) -> PoolStringArray:
	var files := PoolStringArray()
	var dir := Directory.new()
	if dir.open(path) != OK:
		return files
	
	dir.list_dir_begin(true, true) # skip hidden, recursive
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path.plus_file(file_name)
		if not dir.current_is_dir():
			var ext = file_name.get_extension().to_lower()
			if ext in extensions:
				files.append(file_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return files
	
static func screen_to_world(cam :Camera, screen_pos: Vector2) -> Vector3:
	var from = cam.project_ray_origin(screen_pos)
	var dir = cam.project_ray_normal(screen_pos)
	
	var result :Dictionary = cam.get_world().direct_space_state.intersect_ray(
		from, from + dir * 1000, [], 0b11
	)
	if not result.empty():
		return result["position"]
		
	return Vector3.ZERO
	










