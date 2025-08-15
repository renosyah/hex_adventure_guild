extends Control

onready var movable_camera_ui = $SafeArea/VBoxContainer/movable_camera_ui
onready var soldier_icon = $SafeArea/VBoxContainer/HBoxContainer/soldiers/soldier_icon

func _ready():
	soldier_icon.texture =  PotraitGenerator.get_soldier_potrait(4,3)
