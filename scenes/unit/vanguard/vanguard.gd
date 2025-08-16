extends BaseUnit
class_name Vanguard

onready var body = $body
onready var animation_player = $AnimationPlayer

# special ability only for this unit
func activate_spear_defence():
	if not .can_attack():
		return
		
	animation_player.play("spear_defence")
	yield(animation_player,"animation_finished")
	.perform_action()
	
func face_left():
	.face_left()
	
	body.scale.x = -1
	
func face_right():
	.face_right()
	
	body.scale.x = 1
	
func attack_target(unit :BaseUnit):
	if not .can_attack():
		return
		
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

