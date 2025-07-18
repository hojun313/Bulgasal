extends CharacterBody2D

signal health_changed(new_health)
signal defeated

@export var speed = 50.0
@export var health = 100
@export var attack_damage = 10
@export var jump_velocity = -300.0
@export var dash_speed = 300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null

# Nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Timers
@onready var jump_timer: Timer = $JumpTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var charge_timer: Timer = $ChargeTimer

# State
var is_dashing = false
var is_charging = false
var dash_direction = 0
var dash_duration = 0.3
var charge_duration = 0.5

func _ready():
	player = get_parent().find_child("Player")

	# Setup timers
	jump_timer.wait_time = randf_range(2.0, 5.0)
	dash_timer.wait_time = randf_range(3.0, 7.0)
	dash_duration_timer.wait_time = dash_duration
	charge_timer.wait_time = charge_duration


func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = 0
	if player:
		# Determine direction towards player
		direction = sign(player.global_position.x - global_position.x)

	if is_dashing:
		# Dashing movement
		velocity.x = dash_direction * dash_speed
	elif is_charging:
		# Charging, so no movement
		velocity.x = 0
	else:
		# Normal movement towards player
		velocity.x = direction * speed

	# Animation logic
	if not is_on_floor():
		if animated_sprite.animation != "jump":
			animated_sprite.play("jump")
	elif is_charging:
		if animated_sprite.animation != "idle": # Or a specific charging animation if available
			animated_sprite.play("idle")
	elif is_dashing:
		if animated_sprite.animation != "idle": # Or a specific dashing animation if available
			animated_sprite.play("idle")
	else: # On floor, not charging, not dashing
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	# Flip sprite based on direction
	if direction != 0:
		animated_sprite.flip_h = direction == 1 # Assuming default sprite faces left, flip when moving right

	move_and_slide()

func take_damage(amount):
	health -= amount
	health_changed.emit(health)
	print("Boss health: ", health)
	if health <= 0:
		defeated.emit()
		queue_free()

func _on_AttackArea_body_entered(body):
	# Assuming the player has a "take_damage" method
	if body.is_in_group("player"):
		body.take_damage(attack_damage)

func _on_jump_timer_timeout():
	if is_on_floor():
		velocity.y = jump_velocity
		animated_sprite.play("jump")
		animated_sprite.animation_finished.connect(func(): animated_sprite.play("idle"), CONNECT_ONE_SHOT)
	# Reset timer for next jump
	jump_timer.wait_time = randf_range(2.0, 5.0)
	jump_timer.start()

func _on_dash_timer_timeout():
	if is_on_floor() and not is_dashing and not is_charging:
		is_charging = true
		animated_sprite.modulate = Color.YELLOW
		if player:
			dash_direction = sign(player.global_position.x - global_position.x)
		else:
			# If player not found, dash in a random direction
			dash_direction = 1 if randf() > 0.5 else -1
		
		charge_timer.start()

	# Reset timer for next dash
	dash_timer.wait_time = randf_range(3.0, 7.0)
	dash_timer.start()

func _on_charge_timer_timeout():
	is_charging = false
	is_dashing = true
	dash_duration_timer.start()

func _on_dash_duration_timer_timeout():
	is_dashing = false
	animated_sprite.modulate = Color.WHITE
