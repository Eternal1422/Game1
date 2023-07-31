extends RigidBody2D

var in_attack_hitbox = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_attack_hitbox and Global.enemy_in_range and Global.currently_attacking:
		print(in_attack_hitbox)
		queue_free()


func _on_area_2d_area_entered(area):
	in_attack_hitbox = true


func _on_area_2d_area_exited(area):
	in_attack_hitbox = false
