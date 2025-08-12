extends Spatial
class_name HexTile

export var texture :Resource
export var id :Vector2

onready var tile = $tile
onready var label = $label

func _ready():
	update()
	
func update():
	#label.text = "(%s)" % id
	#label.visible = texture != null
	#base.visible = texture != null
	tile.texture = texture
