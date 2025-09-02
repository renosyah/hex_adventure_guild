extends MarginContainer

signal change_team
signal edit

const unit_selection_scene = preload("res://menu/gameplay_battle/ui/unit_control/unit_selection.tscn")

var data :PlayerBattleData

onready var units = $VBoxContainer/HBoxContainer/units
onready var label = $VBoxContainer/HBoxContainer/change_team/Label

func _ready():
	update_display()
	
func update_display():
	label.text = "Player %s\nTeam : %s" % [data.player_id, data.team]
	
	for i in units.get_children():
		units.remove_child(i)
		i.queue_free()
		
	var index = 0
	for i in data.player_units:
		var unit :UnitData = i
		var unit_selection = unit_selection_scene.instance()
		unit_selection.potrait = unit.unit_potrait
		unit_selection.rect_global_position += Vector2.RIGHT * index
		units.add_child(unit_selection)
		units.move_child(unit_selection, 0)
		index += 50

func _on_edit_pressed():
	emit_signal("edit")

func _on_change_team_pressed():
	emit_signal("change_team")
