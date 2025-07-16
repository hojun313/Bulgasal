extends CharacterBody2D

@export var speed = 100.0
@export var jump_velocity = -400.0
@export var projectile_scene: PackedScene
@export var health = 100

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_direction = 1 # 1 for right, -1 for left

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

	if Input.is_action_just_pressed("attack"):
		shoot()

func shoot():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		if facing_direction == -1:
			projectile.rotation_degrees = 180 # Rotate 180 degrees for left direction

func take_damage(amount):
	health -= amount
	print("Player health: ", health)
	if health <= 0:
		queue_free() # Player is defeated
