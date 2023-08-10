extends CharacterBody2D

signal bossHit

var speed = 60.0
var player_chase = false 
var player = null
var state = ''
var attacking = false
var in_attack_hitbox = false
var dying = false

@onready var king_pig = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var can_take_damage = $CanTakeDamage
@onready var health_bar = $HealthBar
@onready var animation_player = $AnimationPlayer
@onready var attacked_animation_player = $AttackedAnimationPlayer


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	material.set_shader_parameter('flash_modifer', 0)
	
func _physics_process(delta):
	print(attacking)
	deal_damage()
	if not is_on_floor():
		velocity.y += gravity * delta
#
	if player_chase and not attacking and not dying:
		var direction = (player.global_position - global_position).normalized()
		if direction.x < 0:
			king_pig.scale.x = scale.y * 1
		else:
			king_pig.scale.x = scale.y * -1
			
		state = 'run'
		velocity.x = move_toward(velocity.x, speed * direction.x, 200 * delta)
		move_and_slide()
		animated_sprite_2d.play(state
		)  
	elif not attacking and not dying:
		state = 'idle'
		animated_sprite_2d.play(state)  
#
func playerHit():
	if attacking:
		emit_signal("bossHit")
#
func deal_damage():
	if in_attack_hitbox and Global.enemy_in_range and Global.currently_attacking and can_take_damage.time_left == 0:
		can_take_damage.start()
		attacked_animation_player.play('hit')
		health_bar.value -= 40
		if health_bar.value <= 0: 
			dying = true
			animated_sprite_2d.play('death')
			await animated_sprite_2d.animation_finished
			queue_free() 
		

func _on_melee_detection_area_area_entered(area):
	player_chase = true
	player = area
	
	
func _on_melee_detection_area_area_exited(area):
	player_chase = false
	player = null


func _on_collision_detection_area_entered(area):
	in_attack_hitbox = true


func _on_collision_detection_area_exited(area):
	in_attack_hitbox = false

func _on_left_melee_area_area_entered(area):
	attacking = true
	while attacking and not dying:
		animation_player.stop()
		animated_sprite_2d.stop()
		animation_player.play("hit")
		await animation_player.animation_finished


func _on_left_melee_area_area_exited(area):
	attacking = false


func _on_right_melee_area_area_entered(area):
	attacking = true
	while attacking and not dying:
		animation_player.stop()
		animated_sprite_2d.stop()
		animated_sprite_2d.play('attack')
		animation_player.play("hit")
		await animation_player.animation_finished


func _on_right_melee_area_area_exited(area):
	attacking = false
