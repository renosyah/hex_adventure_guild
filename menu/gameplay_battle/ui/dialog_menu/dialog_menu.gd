extends Control

signal exit
signal surrender

func _on_close_pressed():
	visible = false

func _on_exit_pressed():
	emit_signal("exit")

func _on_surrender_pressed():
	emit_signal("surrender")
