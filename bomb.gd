extends AnimatedSprite2D

signal playerDiedFromExplosion

@onready var bomb = $"."
var exploded = false    
var safe = true        
var animation_playing = false
	
func _on_area_2d_body_entered(body):
	safe = false
	if not animation_playing:
		animation_playing = true
		bomb.play("on")
		await bomb.animation_finished
		bomb.play("exploded")
		if safe == false:
			emit_signal("playerDiedFromExplosion")
		await bomb.animation_finished
		queue_free()
	
func _on_area_2d_body_exited(body):
	safe = true

