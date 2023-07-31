extends CharacterBody2D

@export var movement_data : PlayerMovementData

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var player = $"."
@onready var starting_position = global_position 
@onready var collision_shape_2d = $HazardDetector/CollisionShape2D
@onready var collision_shape = $CollisionShape
@onready var health_bar = $HealthBar
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var invincibility_timer = $InvincibilityTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_jump = false
var ranleft = false
var state = ''

func _physics_process(delta):
	if invincibility_timer.time_left > 0:
		health_bar.min_value = 150
	else:
		health_bar.min_value = 0

	apply_gravity(delta)
	handle_jump()
	
	handle_attack()
	
	var direction = Input.get_axis("ui_left", "ui_right")
	handle_acceleration(direction, delta)
	handle_air_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	move_and_slide()
	
	update_animations(direction)
	
func handle_attack():
	if Input.is_action_just_pressed("attack"):
		Global.currently_attacking = true
		movement_data.speed = movement_data.speed/2
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
func handle_jump():
	if is_on_floor(): air_jump = true
	if is_on_floor():
		if Input.is_action_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("ui_accept") and velocity.y < movement_data.jump_velocity * 2:
			velocity.y = movement_data.jump_velocity / 2
		if Input.is_action_just_pressed("ui_accept") and air_jump:
			velocity.y = movement_data.jump_velocity * 0.9
			air_jump = false
			
func handle_acceleration(direction, delta):
	if not is_on_floor(): return
	if direction != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.acceleration * delta)

func handle_air_acceleration(direction, delta):
	if is_on_floor(): return
	if direction != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.air_acceleration * delta)

func apply_friction(direction, delta):
	if direction == 0 and is_on_floor:
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
	
func apply_air_resistance(direction, delta):
	if direction == 0 and not is_on_floor:
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
	
func update_animations(direction):
	if Global.currently_attacking == true:
		state = "attack"
		animated_sprite_2d.play(state)
		await animated_sprite_2d.animation_finished
		Global.currently_attacking = false
		movement_data.speed = 150
		return

	if direction != 0:
		if direction < 0:
			state = "run"
			player.scale.x = scale.y * -1
		else:
			state = "run"
			player.scale.x = scale.y * 1
	else:
		state = "idle"
			
	animated_sprite_2d.play(state)
	
	if not is_on_floor():
#		animated_sprite_2d.play("jump")
		pass


func playerDied():
	set_physics_process(false) 
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	global_position = starting_position 
	set_physics_process(true) 
	health_bar.value = 150
	invincibility_timer.start()
	health_bar.min_value = 0

func _on_bomb_player_died_from_explosion():
	health_bar.value -= 120
	if health_bar.value <= 0:
		playerDied()
	
func _on_pig_character_hit():
	health_bar.value -= 30
	if health_bar.value <= 0:
		playerDied()

func _on_right_attack_area_area_entered(area):
	Global.enemy_in_range = true

func _on_right_attack_area_area_exited(area):
	Global.enemy_in_range = false

func _on_heart_health_pickup():
	health_bar.value += 25
