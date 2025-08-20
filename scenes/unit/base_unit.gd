extends Spatial
class_name BaseUnit

signal unit_leave_tile(_unit, _tile_id)
signal unit_enter_tile(_unit, _tile_id)
signal unit_consume_action(_unit)
signal unit_consume_move(_unit)
signal unit_on_turn(_unit)
signal unit_attack_target(_unit, _target)
signal unit_take_damage(_unit, _damage, _from_unit)
signal unit_dead(_unit, _tile_id)
signal unit_reach(_unit, _tile_id)

# for ui need
signal unit_selected

# owner
export var player_id :int
export var team :int

export var action :int = 1
export var max_action :int = 1

export var move :int = 1
export var move_range :int = 1

export var hp :int = 25
export var max_hp :int = 25
export var armor :int = 2

export var attack_damage :int = 14
export var attack_range :int = 1

export var view_range :int = 2
export var move_speed :float = 0.4

export var is_hidden :bool
export var weapon_model :Resource

# for ui need
export var is_selected :bool

var _tween_move :Tween
var _current_attack_damage :int
var _current_facing :int = 1
var _melee_tiles :Array = []

# path is array of tile id & position 3d
var paths :Array = [] # [ [Vector2, Vector3] ] 
var current_tile :Vector2

func _ready():
	_tween_move = Tween.new()
	_tween_move.connect("tween_completed", self, "_on_move_completed")
	add_child(_tween_move)
	_prepare_attack_damage()

func _prepare_attack_damage():
	var partial = int(attack_damage * 0.25)
	var min_dmg = clamp(attack_damage - partial, 1, attack_damage)
	var max_dmg = attack_damage + partial
	_current_attack_damage = int(rand_range(min_dmg, max_dmg))

func unit_selected(v :bool):
	is_selected = v
	emit_signal("unit_selected")

#  overidable func
func has_action() -> bool:
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
	
func unit_spotted():
	if is_dead():
		return
		
	is_hidden = false
	visible = not is_hidden
	
func on_unit_move() -> void:
	pass
	
func on_unit_stop():
	_melee_tiles = HexMapUtil.get_adjacent_tile_common(current_tile)
	emit_signal("unit_reach", self, current_tile)
	
func take_damage(dmg :int, from :BaseUnit) -> void:
	if is_dead():
		return
		
	var damage_receive :int = clamp(dmg - armor, 1, dmg) if (dmg > 0) else 0
	hp = clamp(hp - damage_receive, 0, max_hp)
	
	unit_taken_damage(damage_receive, from)
	
	if is_dead():
		emit_signal("unit_dead", self, current_tile)
	
func unit_taken_damage(dmg :int, from :BaseUnit):
	emit_signal("unit_take_damage", self, dmg, from)
	
func on_turn():
	action = max_action
	move = move_range
	_prepare_attack_damage()
	emit_signal("unit_on_turn", self)
	
func use_ability() -> void:
	pass
	
func perfom_action_attack(target :BaseUnit) -> void:
	if not has_action():
		return
		
	attack_target(target)
	consume_action()
	
func attack_target(target :BaseUnit) -> void:
	if not is_instance_valid(target):
		return
		
	if not target.is_dead():
		target.take_damage(get_attack_damage(), self)
		emit_signal("unit_attack_target", self, target)
	
func facing_pos(pos :Vector3):
	if pos.x < global_position.x and _current_facing == 1:
		face_left()
	elif pos.x > global_position.x and _current_facing == -1:
		face_right()
		
func consume_action() -> void:
	action = clamp(action - 1, 0, max_action)
	emit_signal("unit_consume_action", self)
	
func consume_movement() -> void:
	move = clamp(move - 1, 0, move_range)
	emit_signal("unit_consume_move", self)
	
# move will be called externaly
# it because on unit move and enter
# new tile, must be validate by game master
# like unit enter a trap or something
func move_unit() -> void:
	if paths.empty() or is_dead():
		return
		
	emit_signal("unit_leave_tile", self, current_tile)
	
	var path = paths.front()
	var _move_to = path[1]
	current_tile = path[0]
	
	facing_pos(_move_to)
	
	if not is_hidden:
		_tween_move.interpolate_property(self, "global_position", global_position, _move_to, move_speed)
		_tween_move.start()
		on_unit_move()
	
	else:
		global_position = _move_to
		on_unit_move()
		yield(get_tree(), "idle_frame")
		_on_move_completed(self, "global_position")
	
func _on_move_completed(object: Object, key: NodePath):
	consume_movement()
	
	paths.pop_front()
	
	if paths.empty():
		on_unit_stop()
		
	else:
		emit_signal("unit_enter_tile", self, current_tile)









