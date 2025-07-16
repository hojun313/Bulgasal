extends CharacterBody2D

signal health_changed(new_health)
signal defeated
signal cooldown_updated(time_left)

@export var speed = 100.0
@export var jump_velocity = -400.0
@export var projectile_scene: PackedScene
@export var health = 100

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_direction = 1 # 1 for right, -1 for left
var can_shoot = true
@export var shoot_cooldown = 0.5 # 쿨다운 시간 (초)
var current_cooldown_time = 0.0 # 현재 쿨다운 남은 시간

func _physics_process(delta):
	# Add the gravity. (Vertical movement)
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump. (Vertical movement)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the horizontal movement.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		facing_direction = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	if Input.is_action_just_pressed("attack") and can_shoot:
		shoot()
		can_shoot = false
		current_cooldown_time = shoot_cooldown
		cooldown_updated.emit(current_cooldown_time)

	if not can_shoot:
		current_cooldown_time -= delta
		if current_cooldown_time <= 0:
			can_shoot = true
			current_cooldown_time = 0.0
		cooldown_updated.emit(current_cooldown_time)

func shoot():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position + Vector2(facing_direction * 20, 0) # 총알 생성 위치 조정
		projectile.direction = facing_direction
		if facing_direction == -1:
			projectile.rotation_degrees = 180 # Rotate 180 degrees for left direction

func take_damage(amount):
	health -= amount
	health_changed.emit(health)
	print("Player health: ", health)
	if health <= 0:
		defeated.emit()
		queue_free() # Player is defeated
