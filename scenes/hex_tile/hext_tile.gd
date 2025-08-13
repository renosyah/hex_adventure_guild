extends Spatial
class_name HexTile

export var texture :Resource
export var id :Vector2

onready var tile = $tile
onready var label = $label

func _ready():
	label.visible = false
	update()
	
func get_object_position() -> Vector3:
	return tile.global_position + Vector3.FORWARD * 0.3
	
func show_label(v :bool):
	label.text = "%s" % id
	label.visible = v
	label.translation = global_position + Vector3(0, label.translation.y, 0)
	
func update():
	tile.texture = texture
