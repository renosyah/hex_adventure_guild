extends BaseUnit
class_name Vanguard

onready var body = $body
onready var animation_player = $AnimationPlayer
onready var weapon = $body/weapon

var _is_spear_defence_activated :bool = false
var _spear_defence_area :Array = []

func _ready():
	weapon.texture = weapon_model

# special ability only for this unit
func activate_spear_defence():
	if not .has_action():
		return
		
	_spear_defence_area = HexMapUtil.get_adjacent_tile_common(current_tile)
	_is_spear_defence_activated = true
	
	.consume_action()
	
	animation_player.play("spear_defence")
	yield(animation_player,"animation_finished")
	
func is_enemy_enter_area(target :BaseUnit, id :Vector2) -> bool:
	if not _is_spear_defence_activated:
		return false
	
	if not _spear_defence_area.has(id):
		return false
		
	if target.team == team:
		return false
		
	attack_target(target)
	
	_is_spear_defence_activated = false
	return true
	
func on_turn():
	.on_turn()
	
	animation_player.play("iddle")
	_is_spear_defence_activated = false
	
func unit_taken_damage(dmg :int, from :BaseUnit):
	.unit_taken_damage(dmg, from)
	
	animation_player.play("damage")
	
func face_left():
	.face_left()
	
	body.scale.x = -1
	
func face_right():
	.face_right()
	
	body.scale.x = 1
	
func attack_target(target :BaseUnit):
	if not target.is_dead():
		.facing_pos(target.global_position)
		animation_player.play("attack")
		yield(animation_player,"animation_finished")
		animation_player.play("iddle")
	
	.attack_target(target)
	
func on_unit_move() -> void:
	.on_unit_move()
	
	animation_player.play("walk")
	
func on_unit_stop():
	.on_unit_stop()
	
	animation_player.play("iddle")

