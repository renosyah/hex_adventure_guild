extends MarginContainer

signal edit
signal delete

var data :HexMapFileManifest

onready var texture_rect = $VBoxContainer/HBoxContainer/TextureRect
onready var map_name = $VBoxContainer/HBoxContainer/VBoxContainer/map_name
onready var map_size = $VBoxContainer/HBoxContainer/VBoxContainer/map_size

func _ready():
	var img = Image.new()
	img.load(data.map_image)
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	texture_rect.texture = tex
	
	map_name.text = data.map_name
	map_size.text = "Map size : %s" % data.map_size


func _on_edit_pressed():
	emit_signal("edit")

func _on_delete_pressed():
	emit_signal("delete")
