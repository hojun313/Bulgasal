extends Node2D

@export var game_end_ui_scene: PackedScene
@export var blacksmith_scene: PackedScene
@export var duoksin_scene: PackedScene

func _ready():
	print("Main scene loaded!")

	var player = $Player
	var boss = duoksin_scene.instantiate() # Instantiate Duoksin directly
	add_child(boss)
	boss.position = Vector2(100, 300) # Set initial position

	var player_health_bar = $UI/PlayerHealthBar
	var boss_health_bar = $UI/BossHealthBar

	if player and player_health_bar:
		player_health_bar.max_value = player.health
		player_health_bar.value = player.health
		player.health_changed.connect(func(new_health):
			player_health_bar.value = new_health
		)
		player.defeated.connect(_on_player_defeated)

	if boss and boss_health_bar:
		boss_health_bar.max_value = boss.health
		boss_health_bar.value = boss.health
		boss.health_changed.connect(func(new_health):
			boss_health_bar.value = new_health
		)
		boss.defeated.connect(_on_boss_defeated)

func _on_player_defeated():
	show_game_end_ui("Game Over!")

func _on_boss_defeated():
	var current_boss = get_node_or_null("Duoksin") # Get the current boss node
	if current_boss:
		current_boss.call_deferred("queue_free") # Remove the defeated boss
	get_tree().change_scene_to_file(blacksmith_scene.resource_path)

func show_game_end_ui(message):
	if game_end_ui_scene:
		var game_end_ui = game_end_ui_scene.instantiate()
		add_child(game_end_ui)
		game_end_ui.get_node("ColorRect/MessageLabel").text = message
		game_end_ui.get_node("ColorRect/RestartButton").pressed.connect(self._on_restart_button_pressed)
