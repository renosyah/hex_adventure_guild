extends BaseUnit
class_name Knight

onready var animation_player = $AnimationPlayer
onready var body = $body
onready var weapon = $body/weapon

var _is_counter_activated :bool = false
var _chance_to_avoid_damage :float = 0.15

func _ready():
	weapon.texture = weapon_model
	
func use_ability() -> void:
	.use_ability()
	
	if not .has_action():
		return
		
	_is_counter_activated = true
	.consume_action()
	
	animation_player.play("armor_defence")
	yield(animation_player,"animation_finished")
	
func take_damage(dmg :int, from :BaseUnit) -> void:
	var _damage :int = dmg
	
	# have chance to receive no damage
	var blocked :bool = randf() < _chance_to_avoid_damage
	if _is_counter_activated and blocked:
		_damage = 0
	
	.take_damage(_damage, from)
	
func unit_taken_damage(dmg :int, from :BaseUnit):
	.unit_taken_damage(dmg, from)
	
	animation_player.play("damage")
	
	if _is_counter_activated and not is_dead():
		
		# retaliate counter
		# only counter
		# if enemy in melee range
		# of not, well, ability is interupted
		# you wait for sword but got arrow in knee instead
		if _melee_tiles.has(from.current_tile):
			yield(animation_player,"animation_finished")
			_current_attack_damage = from.get_attack_damage()
			attack_target(from)
			
		_is_counter_activated = false
	
func on_turn():
	.on_turn()
	
	animation_player.play("iddle")
	_is_counter_activated = false
	
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
