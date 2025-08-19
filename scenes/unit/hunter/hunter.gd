extends BaseUnit
class_name Hunter

var arrow_scene = preload("res://scenes/projectile/arrow/arrow.tscn")

onready var body = $body
onready var animation_player = $AnimationPlayer
onready var bow = $body/bow

func on_turn():
	.on_turn()
	
	animation_player.play("iddle")
	
func _fire_arrow(at :Vector3):
	var arrow = arrow_scene.instance()
	arrow.target = at + Vector3.UP * 0.7
	add_child(arrow)
	arrow.translation = bow.global_position
	arrow.fire()
	yield(arrow,"hit")
	arrow.queue_free()
	
func attack_target(target :BaseUnit):
	if not target.is_dead():
		.facing_pos(target.global_position)
		
		if _melee_tiles.has(target.current_tile):
			# because unit use melee
			# force change attack damage value
			_current_attack_damage = int(rand_range(1,4))
			animation_player.play("attack_melee")
			
		else:
			animation_player.play("attack")
			_fire_arrow(target.global_position)
			
		yield(animation_player,"animation_finished")
		animation_player.play("iddle")
	
	.attack_target(target)
	
func face_left():
	.face_left()
	
	body.scale.x = -1
	
func face_right():
	.face_right()
	
	body.scale.x = 1
	
func on_unit_move() -> void:
	.on_unit_move()
	
	animation_player.play("walk")
	
func on_unit_stop():
	.on_unit_stop()
	
	animation_player.play("iddle")
