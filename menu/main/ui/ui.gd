extends Control
onready var loading = $loading

func _ready():
	loading.visible = false
	
func _on_editor_pressed():
	get_tree().change_scene("res://menu/editor_menu/editor_menu.tscn")

func _on_battle_pressed():
	Global.selected_map_data = null
	Global.player_battle_data.clear()
	
	get_tree().change_scene("res://menu/battle_menu/battle_menu.tscn")
