extends Control

func _on_editor_pressed():
	Global.selected_map_data = HexMapUtil.generate_empty_map()
	get_tree().change_scene("res://menu/editor/editor.tscn")
