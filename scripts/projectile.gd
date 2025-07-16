extends Area2D

@export var speed = 150.0 # 총알 속도를 늦춥니다.
@export var life_time = 2.0 # 총알 수명 (초)
var direction = 1 # 1 for right, -1 for left

func _physics_process(delta):
	position.x += direction * speed * delta
	life_time -= delta
	if life_time <= 0:
		queue_free()

func _on_body_entered(body):
	if body.name == "Duoksin": # 보스에게만 피해를 줍니다.
		if body.has_method("take_damage"):
			body.take_damage(10) # 예시 피해량
		queue_free() # 보스와 충돌했을 때만 총알이 사라집니다.
	else:
		# 보스가 아닌 다른 오브젝트와 충돌했을 때 총알이 사라지지 않도록 합니다.
		# 필요에 따라 여기에 다른 로직을 추가할 수 있습니다.
		pass
