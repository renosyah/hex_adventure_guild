extends Node
class_name PotraitGenerator

const soldiers = preload("res://assets/potrait/soldiers/soldier_1.png")
const monsters = preload("res://assets/potrait/monsters/monsters.png")
const banners = preload("res://assets/potrait/banners/symbols.png")

static func get_soldier_potrait(col: int, row: int) -> AtlasTexture:
	var cell_size: Vector2 = Vector2(128, 135)
	var atlas = AtlasTexture.new()
	atlas.atlas = soldiers
	var x = (clamp(col, 0, 8) * cell_size.x) + 2
	var y = (clamp(row, 0, 11) * cell_size.y) + (2 * row)
	atlas.region = Rect2(x, y, cell_size.x, cell_size.y)
	return atlas
	
static func get_monsters_potrait(col: int, row: int) -> AtlasTexture:
	var cell_size: Vector2 = Vector2(240, 260)
	var atlas = AtlasTexture.new()
	atlas.atlas = monsters
	var x = (clamp(col, 0, 4) * cell_size.x) + 30
	var y = (clamp(row, 0, 6) * cell_size.y) - (5 * row)
	atlas.region = Rect2(x, y, cell_size.x, cell_size.y)
	return atlas
	
static func get_banners_potrait(col: int, row: int) -> AtlasTexture:
	var cell_size: Vector2 = Vector2(260, 280)
	var atlas = AtlasTexture.new()
	atlas.atlas = banners
	var x = (clamp(col, 0, 4) * cell_size.x)
	var y = (clamp(row, 0, 7) * cell_size.y) - (60 * row)
	atlas.region = Rect2(x, y, cell_size.x, cell_size.y)
	return atlas
