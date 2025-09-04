extends MarginContainer

signal on_unit_select(unit)

const unit_selection_scene = preload("res://menu/gameplay_battle/ui/unit_control/unit_selection.tscn")

onready var _label = $VBoxContainer/HBoxContainer2/Label
onready var _units = $VBoxContainer/HBoxContainer/units

var unit_class :int
var units :Array

func _ready():
	_label.text = UnitUtils.get_unit_class_name(unit_class)
	for i in units:
		var unit :UnitData = i
		var item = unit_selection_scene.instance()
		item.potrait = i.unit_potrait
		item.connect("pressed", self, "_on_unit_select", [unit])
		_units.add_child(item)
		
func _on_unit_select(unit):
	emit_signal("on_unit_select", unit)
