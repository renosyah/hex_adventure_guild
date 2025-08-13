extends MarginContainer

signal on_randomize
signal on_land_tile
signal on_hill_tile
signal on_water_tile

func _on_btn_tile_random_pressed():
	emit_signal("on_randomize")

func _on_btn_tile_land_pressed():
	emit_signal("on_land_tile")

func _on_btn_tile_hill_pressed():
	emit_signal("on_hill_tile")

func _on_btn_tile_water_pressed():
	emit_signal("on_water_tile")
