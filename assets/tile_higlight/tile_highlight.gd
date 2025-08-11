extends Spatial

const attack = preload("res://assets/tile_higlight/attack.png")
const move = preload("res://assets/tile_higlight/move.png")

onready var icon = $Spatial/icon

func show():
	icon.texture = null
	
func show_attack():
	icon.texture = attack

func show_move():
	icon.texture = move
