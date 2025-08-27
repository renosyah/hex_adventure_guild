extends Control

signal create(name, size)

onready var map_name = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/map_name
onready var size_buttons = {
	6:$"MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/6",
	8:$"MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/8",
	10:$"MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/10",
	12:$"MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/12",
}

var size :int = 6

func _ready():
	for key in size_buttons.keys():
		var btn :Button = size_buttons[key]
		btn.connect("pressed", self, "_btn_size_press", [btn, key])
		
func _btn_size_press(btn, key):
	size = key
	
	for key in size_buttons.keys():
		var b :Button = size_buttons[key]
		b.pressed = b == btn
	
func _on_create_new_pressed():
	if map_name.text.empty():
		return
		
	emit_signal("create", map_name.text, size)

func _on_cancel_pressed():
	visible = false


func _on_random_name_pressed():
	map_name.text = RandomNameGenerator.generate_name().to_lower()
