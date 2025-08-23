extends Control

const ally_icon = preload("res://menu/gameplay_battle/ui/unit_floating_info/ally.png")
const enemy_icon = preload("res://menu/gameplay_battle/ui/unit_floating_info/enemy.png")

export var is_for :int # 1 = player, 2 = enemy 3 = ally
export var is_player :bool

onready var h_box_container = $MarginContainer/HBoxContainer
onready var label = $MarginContainer/HBoxContainer/Label
onready var texture_rect_2 = $MarginContainer/TextureRect2
onready var texture_rect = $MarginContainer/TextureRect

func _ready():
	h_box_container.visible = false
	texture_rect_2.visible = false
	
	match is_for:
		1:
			h_box_container.visible = true
		2:
			texture_rect_2.visible = true
			texture_rect_2.texture = enemy_icon
		3:
			texture_rect_2.visible = true
			texture_rect_2.texture = ally_icon
	
func set_hp(v :int):
	label.text = "%s" % v

func unit_take_damage(_unit: BaseUnit, _dmg, from):
	label.text = "%s" % _unit.hp
	
func unit_dead(_unit, _tile):
	queue_free()
