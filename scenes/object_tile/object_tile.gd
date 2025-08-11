extends Spatial
class_name ObjectTile

onready var cam :Camera = get_viewport().get_camera()
export var texture :Resource
onready var obj = $obj

func _ready():
	update()
	
func update():
	obj.texture = texture
