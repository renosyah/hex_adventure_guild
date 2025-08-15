extends Spatial
class_name HexTile

export var texture :Resource
export var id :Vector2
var object

export var tile :NodePath
export var label :NodePath
export var fog :NodePath
export var tile_body :NodePath

onready var _tile = get_node_or_null(tile)
onready var _label = get_node_or_null(label)
onready var _fog = get_node_or_null(fog)
onready var _tile_body = get_node_or_null(tile_body)

func _ready():
	_label.visible = false
	_label.set_as_toplevel(true)
	update()
	
func get_object_position() -> Vector3:
	return _tile.global_position + Vector3.FORWARD * 0.3
	
func show_label(v :bool):
	_label.text = "%s" % id
	_label.visible = v
	_label.translation = global_position + Vector3(0, _label.translation.y, 0)
	
func set_discovered(v :bool):
	_fog.visible = ! v
	_tile_body.visible = v
	
	if object:
		object.visible = v
	
func update():
	_tile.texture = texture
