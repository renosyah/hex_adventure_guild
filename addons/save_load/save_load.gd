extends Node
class_name SaveLoad

const prefix = "user://"

static func save_data_small(path: String, data):
	var p = "%s%s" % [prefix, path]
	var file = File.new()
	var b64 = Marshalls.variant_to_base64(data)
	var bytes = Marshalls.base64_to_raw(b64)
	bytes = bytes.compress(File.COMPRESSION_DEFLATE) # compress manually
	file.open(p, File.WRITE)
	file.store_buffer(bytes)
	file.close()

static func load_data_small(path: String):
	var p = "%s%s" % [prefix, path]
	var file = File.new()
	if not file.file_exists(p):
		return null
		
	file.open(p, File.READ)
	var bytes :PoolByteArray = file.get_buffer(file.get_len())
	bytes = bytes.decompress(1048576, File.COMPRESSION_DEFLATE) # 1MB max size
	var b64 = Marshalls.raw_to_base64(bytes)
	var data = Marshalls.base64_to_variant(b64)
	file.close()
	return data
	
static func save(_filename: String, _data):
	var file = File.new()
	file.open(prefix + _filename, File.WRITE)
	file.store_var(_data, true)
	file.close()

static func load_save(_filename : String):
	var file = File.new()
	if file.file_exists(prefix + _filename):
		file.open(prefix + _filename, File.READ)
		var _data = file.get_var(true)
		file.close()
		return _data
	return null

static func delete_save(_filename : String):
	var dir = Directory.new()
	dir.remove(prefix + _filename)
