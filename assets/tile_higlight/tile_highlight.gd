extends Spatial

const attack = preload("res://assets/tile_higlight/attack.png")
const move = preload("res://assets/tile_higlight/move.png")
const view = preload("res://assets/tile_higlight/view.png")
onready var icon = $Spatial/icon

func show():
	icon.texture = null
	
func show_attack():
	icon.texture = attack
	
func show_view():
	icon.texture = view

func show_move():
	icon.texture = move
