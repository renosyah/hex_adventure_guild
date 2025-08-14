extends Control

onready var soldier_icon = $HBoxContainer/soldiers/soldier_icon
onready var monster_icon = $HBoxContainer/monster/monster_icon
onready var banner_color = $HBoxContainer/banners/banner_color
onready var banner_icon = $HBoxContainer/banners/banner_icon

func _ready():
	for i in 11:
		for o in 8:
			soldier_indexs.append([i, o])
	
	for i in 6:
		for o in 4:
			monster_indexs.append([i, o])
	
	for i in 6:
		for o in 4:
			banners_indexs.append([i, o])
			
var soldier_indexs = []
var soldier_pos = 0

func _on_soldiers_pressed():
	soldier_icon.texture = PotraitGenerator.get_soldier_potrait(
		soldier_indexs[soldier_pos][1],soldier_indexs[soldier_pos][0]
	)
	soldier_pos = soldier_pos + 1 if soldier_pos < (soldier_indexs.size() - 1) else 0

var monster_indexs = []
var monster_pos = 0

func _on_monster_pressed():
	monster_icon.texture = PotraitGenerator.get_monsters_potrait(
		monster_indexs[monster_pos][1],monster_indexs[monster_pos][0]
	)
	monster_pos = monster_pos + 1 if monster_pos < (monster_indexs.size() - 1) else 0

var banners_indexs = []
var banners_pos = 0

func _on_banners_pressed():
	banner_icon.texture = PotraitGenerator.get_banners_potrait(
		banners_indexs[banners_pos][1],banners_indexs[banners_pos][0]
	)
	#banner_icon.modulate = Color(randf(),randf(),randf(), 1)
	#banner_color.color = Color(randf(),randf(),randf(), 1)
	banners_pos = banners_pos + 1 if banners_pos < (banners_indexs.size() - 1) else 0











