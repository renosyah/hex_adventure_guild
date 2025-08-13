extends MarginContainer

signal on_change_range(v)

var _range_index = 0
var _ranges = [2, 3, 4]

onready var btns = [
	$HBoxContainer/VBoxContainer2/btn_adjacent,
	$HBoxContainer/VBoxContainer2/btn_view,
	$HBoxContainer/VBoxContainer2/btn_path
]
onready var btn_range = $HBoxContainer/VBoxContainer2/btn_range/Label

func _ready():
	btns[0].toggle(true)
	
	for i in btns:
		i.connect("pressed", self , "_btn_press", [i])
		
func _btn_press(btn):
	for i in btns:
			i.toggle(i == btn)
		
func _on_btn_range_pressed():
	_range_index = _range_index + 1 if _range_index < 2 else 0
	btn_range.text = "x%s" % _ranges[_range_index]
	emit_signal("on_change_range", _ranges[_range_index])
