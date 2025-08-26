extends Control

signal on_save
signal on_load
signal on_exit

func _on_save_pressed():
	visible = false
	emit_signal("on_save")

func _on_load_pressed():
	emit_signal("on_load")

func _on_exit_pressed():
	emit_signal("on_exit")

func _on_close_pressed():
	visible = false
