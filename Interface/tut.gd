extends Control

onready var anim = $AnimationPlayer

func _ready():
	anim.play("dissolve")
	yield(anim,"animation_finished")
	anim.play("tut")
