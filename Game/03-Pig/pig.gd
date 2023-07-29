extends CharacterBody2D

signal characterHit

var speed = 60.0
var player_chase = false 
var player = null
var state = ''
var attacking = false
var in_attack_hitbox = false

@onready var pig = $"."
@onready var can_take_damage = $CanTakeDamage
@onready var health_bar = $HealthBar
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
func _physics_process(delta):
	
	deal_damage()
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if player_chase and not attacking:
		var direction = (player.global_position - global_position).normalized()
		if direction.x < 0:
			pig.scale.x = scale.y * 1
		else:
			pig.scale.x = scale.y * -1
		state = 'run'
		velocity.x = move_toward(velocity.x, speed * direction.x, 200 * delta)
		move_and_slide()
		animated_sprite_2d.play(state
		)  
	elif not attacking:
		state = 'idle'
		animated_sprite_2d.play(state)  

func _on_detection_area_area_entered(area):
	player = area
	player_chase = true

func _on_detection_area_area_exited(area):
	player = null
	player_chase = false

func _on_left_attack_area_area_entered(area):
	attacking = true
	while attacking:
		state = 'attack'
		animated_sprite_2d.play(state)
		animation_player.play("attack")
		await animation_player.animation_finished

func _on_left_attack_area_area_exited(area):
	attacking = false
	animated_sprite_2d.flip_h = false

func _on_right_attack_area_area_entered(area):
	attacking = true
	animated_sprite_2d.flip_h = true
	while attacking:
		state = 'attack'
		animated_sprite_2d.play(state)
		animation_player.play("attack")
		await animation_player.animation_finished
		
func _on_right_attack_area_area_exited(area):
	attacking = false
	animated_sprite_2d.flip_h = false
	
func playerHit():
	emit_signal("characterHit")

func deal_damage():
	if in_attack_hitbox and Global.enemy_in_range and Global.currently_attacking == true and can_take_damage.time_left == 0:
		can_take_damage.start()
		health_bar.value -= 40
		if health_bar.value <= 0: 
			queue_free()
			var pigs = get_tree().get_nodes_in_group("Pigs")
			pig.remove_from_group("Pigs")
			if pigs.size() == 1:
				Global.level_completed.emit()

func _on_attack_hit_box_area_entered(area):
	in_attack_hitbox = true

func _on_attack_hit_box_area_exited(area):
	in_attack_hitbox = false
