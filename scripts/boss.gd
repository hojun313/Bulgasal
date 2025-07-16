extends CharacterBody2D

signal health_changed(new_health)
signal defeated

@export var speed = 50.0
@export var health = 100
@export var attack_damage = 10
@export var jump_velocity = -300.0
@export var dash_speed = 300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_timer: Timer
var dash_timer: Timer
var is_dashing = false
var dash_direction = 0
var dash_duration = 0.3

func _ready():
	jump_timer = Timer.new()
	add_child(jump_timer)
	jump_timer.wait_time = randf_range(2.0, 5.0)
	jump_timer.autostart = true
	jump_timer.timeout.connect(_on_jump_timer_timeout)

	dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.wait_time = randf_range(3.0, 7.0)
	dash_timer.autostart = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dashing:
		velocity.x = dash_direction * dash_speed
	else:
		# Simple movement for now, will be replaced with actual boss AI
		velocity.x = speed
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is StaticBody2D: # Assuming walls are StaticBody2D
				speed *= -1 # Reverse direction

	move_and_slide()

func take_damage(amount):
	health -= amount
	health_changed.emit(health)
	print("Boss health: ", health)
	if health <= 0:
		defeated.emit()
		queue_free()

func _on_AttackArea_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)

func _on_jump_timer_timeout():
	if is_on_floor():
		velocity.y = jump_velocity
	jump_timer.wait_time = randf_range(2.0, 5.0)
	jump_timer.start()

func _on_dash_timer_timeout():
	if is_on_floor():
		is_dashing = true
		var player = get_parent().find_child("Player")
		if player:
			dash_direction = sign(player.global_position.x - global_position.x)
		else:
			dash_direction = sign(randf_range(-1.0, 1.0))

		var end_dash_timer = Timer.new()
		add_child(end_dash_timer)
		end_dash_timer.wait_time = dash_duration
		end_dash_timer.one_shot = true
		end_dash_timer.timeout.connect(func():
			is_dashing = false
			end_dash_timer.queue_free()
		)
		end_dash_timer.start()

	dash_timer.wait_time = randf_range(3.0, 7.0)
	dash_timer.start()
