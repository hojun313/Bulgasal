extends Control

@onready var cooldown_label = $"CooldownLabel"

func _ready():
	_on_player_cooldown_updated(0.0) # 초기 상태는 쿨다운 없음

func _on_player_cooldown_updated(time_left: float):
	if time_left > 0:
		cooldown_label.text = "Cooldown: %.1f" % time_left
	else:
		cooldown_label.text = "Cooldown: Ready"
