extends Area2D

@export var speed = 300.0

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(10) # Example damage value
	queue_free()
