extends Spatial

const dead_icon = preload("res://assets/damage_indicator/dead.png")
const dmg_icon =  preload("res://assets/damage_indicator/dmg.png")
export var damage :int

onready var sprite_3d = $Spatial/Sprite3D
onready var animation_player = $AnimationPlayer
onready var label = $Spatial/label

func _ready():
	visible = false

func show_damage():
	sprite_3d.texture = dmg_icon
	visible = true
	label.visible = true
	label.text = "-%s" % damage
	animation_player.play("boom")
	
func show_dead():
	sprite_3d.texture = dead_icon
	label.text = ""
	visible = true
	label.visible = false
	animation_player.play("boom")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	visible = false
