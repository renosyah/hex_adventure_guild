extends Button

const color_select = Color(0.133333, 0.133333, 0.133333)
const color_unselect = Color(1, 1, 1)

export var potrait :Resource

onready var _icon = $potrait/icon
onready var _dead = $potrait/dead
onready var _texture_rect_4 = $potrait/TextureRect4


func _ready():
	_icon.texture = potrait
	_dead.visible = false
	_texture_rect_4.modulate = color_unselect
	
func select(v :bool):
	_texture_rect_4.modulate = color_select if v else color_unselect
	
func set_dead():
	_dead.visible = true
