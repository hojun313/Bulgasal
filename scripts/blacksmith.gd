extends Node2D

@export var jangsanbeom_scene: PackedScene

func _ready():
	pass # Replace with function body.

func _on_ExitArea_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(jangsanbeom_scene.resource_path)
