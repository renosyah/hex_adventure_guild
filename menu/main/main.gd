extends Node

onready var map = $map
onready var tween = $Tween
onready var movable_camera = $movable_camera

var move_pos = 0
var cam_move = [
	{
		"from" : Vector3(-5, 7, -5),
		"to" : Vector3(5, 7, 5),
	},
	{
		"from" : Vector3(5, 7, -5),
		"to" : Vector3(-5, 7, 5)
	},
	{
		"from" : Vector3(-5, 7, 5),
		"to" : Vector3(5, 7, 5)
	},
	{
		"from" : Vector3(5, 7, 5),
		"to" : Vector3(-5, 7, 5)
	}
]

func _ready():
	map.generate_from_data(HexMapUtil.generate_randomize_map(rand_range(-1000, 1000), 4), true)
	move_cam()
	
func move_cam():
	tween.interpolate_property(movable_camera, "translation", cam_move[move_pos]["from"], cam_move[move_pos]["to"], 16)
	tween.start()
	
func _on_Tween_tween_completed(object, key):
	move_pos = int(rand_range(0, cam_move.size()))
	move_cam()
