extends BaseUnit
class_name Peasant

onready var body = $body
onready var animation_player = $AnimationPlayer

func on_turn():
	.on_turn()
	
	animation_player.play("iddle")
	
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

