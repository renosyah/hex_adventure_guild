extends Control

signal end_turn

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui

func _on_end_turn_pressed():
	emit_signal("end_turn")
