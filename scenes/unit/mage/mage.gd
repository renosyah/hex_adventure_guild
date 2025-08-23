extends BaseUnit
class_name Mage

var fireball_scene = preload("res://scenes/projectile/fireball/fireball.tscn")

onready var body = $body
onready var animation_player = $AnimationPlayer
onready var staff = $body/staff

var _fireball_to :Vector3
var _has_ammo :bool = true

func can_use_ability() -> bool:
	return not _has_ammo and .can_use_ability()
	
func use_ability() -> void:
	.use_ability()
	
	if not .has_action():
		return
		
	_has_ammo = true
	
	.consume_action()
	animation_player.play("chanting")
	
func get_attack_range() -> int:
	if not _has_ammo:
		return 1
		
	return .get_attack_range()
	
func on_turn():
	.on_turn()
	
	animation_player.play("iddle")
	
func unit_taken_damage(dmg :int, from :BaseUnit):
	.unit_taken_damage(dmg, from)
	
	animation_player.play("damage")
	
func _casting_fireball():
	var bullet  = fireball_scene.instance()
	bullet.target = _fireball_to + Vector3.UP * 0.7
	add_child(bullet)
	bullet.translation = staff.global_position
	bullet.fire()
	yield(bullet,"hit")
	bullet.queue_free()
	
func face_left():
	.face_left()
	
	body.scale.x = -1
	
func face_right():
	.face_right()
	
	body.scale.x = 1
	
func attack_target(target :BaseUnit):
	if target.is_dead():
		.attack_target(target)
		return
		
	var use_melee :bool = _melee_tiles.has(target.current_tile)
	.facing_pos(target.global_position)
	
	if use_melee:
		# because unit use melee
		# force change attack damage value
		_current_attack_damage = int(rand_range(1,4))
		animation_player.play("attack_melee")
		
	else:
		_has_ammo = false
		_fireball_to = target.global_position
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

