extends Spatial
class_name BaseUnit

signal unit_enter_tile(_unit, _tile_id)
signal unit_take_damage(_unit, _damage, _from_unit)
signal unit_dead(_unit)
signal on_reach(_unit, _tile_id)

export var action :int = 1
export var move :int = 1
export var hp :int = 25
export var max_hp :int = 25
export var attack_damage :int = 4
export var move_range :int = 1
export var attack_range :int = 1
export var view_range :int = 2
export var move_speed :float = 0.7

var _tween_move :Tween
var _current_attack_damage :int
var _current_facing :int = 1

# path is array of tile id & position 3d
var paths :Array = [] # [ [Vector2, Vector3] ] 
var current_tile :Vector2

func _ready():
	_tween_move = Tween.new()
	_tween_move.connect("tween_completed", self, "_on_move_completed")
	add_child(_tween_move)
	
	_set_attack_damage()

func _set_attack_damage():
	var partial = int(attack_damage * 0.25)
	var min_dmg = clamp(attack_damage - partial, 1, attack_damage)
	var max_dmg = attack_damage + partial
	_current_attack_damage = int(rand_range(min_dmg, max_dmg))

#  overidable func
func can_attack() -> bool:
	return action > 0
	
func can_move() -> bool:
	return action > 0 and move > 0
	
func is_dead() -> bool:
	return hp == 0
	
func get_spotting_range() -> int:
	return view_range
	
func get_attack_damage() -> int:
	return _current_attack_damage
	
func face_left():
	_current_facing = -1
	
func face_right():
	_current_facing = 1
	
func on_unit_move() -> void:
	pass
	
func on_unit_stop():
	emit_signal("on_reach", self, current_tile)
	
func take_damage(dmg :int, from :BaseUnit) -> void:
	if is_dead():
		return
		
	hp = clamp(hp - dmg, 0, max_hp)
	
	if is_dead():
		emit_signal("unit_dead", self)
		return
		
	emit_signal("unit_take_damage", dmg, from)
	
func on_turn():
	action = 1
	move = 1
	_set_attack_damage()
	
func attack_target(unit :BaseUnit) -> void:
	if is_instance_valid(unit):
		unit.take_damage(get_attack_damage(), self)
		perform_action()
	
func perform_action() -> void:
	action = 0
	
# move will be called externaly
# it because on unit move and enter
# new tile, must be validate by game master
# like unit enter a trap or something
func move() -> void:
	move = 0
	
	if paths.empty():
		return
		
	var path = paths.front()
	current_tile = path[0]
	var _move_to = path[1]
	
	if _move_to.x < global_position.x and _current_facing == 1:
		face_left()
	elif _move_to.x > global_position.x and _current_facing == -1:
		face_right()
		
	_tween_move.interpolate_property(self, "global_position", global_position, _move_to, move_speed)
	_tween_move.start()
	

func _on_move_completed(object: Object, key: NodePath):
	on_unit_move()
	
	paths.pop_front()
	
	if paths.empty():
		on_unit_stop()
		return
		
	emit_signal("unit_enter_tile", self, current_tile)










