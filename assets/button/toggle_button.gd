extends Button
class_name ToggleButton

export var button_icon :Resource

onready var texture_rect_2 = $Control/MarginContainer/Control/TextureRect2
onready var toggle = $Control/MarginContainer/toggle
onready var animation_player = $AnimationPlayer

func _ready():
	update_icon()
	connect("pressed", self ,"_on_toggle_button_pressed")

func update_icon():
	texture_rect_2.texture = button_icon

func toggle(v):
	toggle.visible = v

func is_toggled():
	return toggle.visible

func _on_toggle_button_pressed():
	animation_player.play("pressed")
