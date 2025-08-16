extends BaseUnit
class_name Vanguard

onready var body = $body
onready var animation_player = $AnimationPlayer

var _is_spear_defence_activated :bool = true

# special ability only for this unit
func perfom_action_activate_spear_defence():
	if not _is_spear_defence_activated or not .has_action():
		return
		
	_is_spear_defence_activated = true
	.consume_action()
	
	animation_player.play("spear_defence")
	yield(animation_player,"animation_finished")
	
func is_enemy_enter_area(target :BaseUnit) -> bool:
	if not _is_spear_defence_activated:
		return false
	
	var nearby_tiles = HexMapUtil.get_adjacent_tile_common(current_tile)
	if not nearby_tiles.has(target.current_tile):
		return false
		
	attack_target(target)
	
	_is_spear_defence_activated = false
	return true
	
func unit_taken_damage(dmg :int, from :BaseUnit):
	
	animation_player.play("damage")
	yield(animation_player,"animation_finished")
	
	.unit_taken_damage(dmg, from)
	
func face_left():
	.face_left()
	
	body.scale.x = -1
	
func face_right():
	.face_right()
	
	body.scale.x = 1
	
func attack_target(unit :BaseUnit):
	
	.facing_pos(unit.global_position)
	animation_player.play("attack")
	yield(animation_player,"animation_finished")
	animation_player.play("iddle")
	
	.attack_target(unit)
	
func on_unit_move() -> void:
	.on_unit_move()
	
	animation_player.play("walk")
	
func on_unit_stop():
	.on_unit_stop()
	
	animation_player.play("iddle")

