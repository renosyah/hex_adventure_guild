extends Control

signal close

onready var message = $MarginContainer/VBoxContainer/message

func set_message(v :String):
	message.text = v
	
func _on_ok_pressed():
	visible = false
	emit_signal("close", true)
	
func _on_cancel_pressed():
	visible = false
	emit_signal("close", false)
