extends Node2D

signal healthPickup

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.play('idle')

func _on_area_2d_area_entered(area):
	queue_free()
	emit_signal('healthPickup')
