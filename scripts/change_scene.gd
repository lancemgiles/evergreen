extends Area2D

@export var level = 2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var scene_path = "res://scenes/level_" + str(level) + ".tscn"
		get_tree().change_scene_to_file(scene_path)
		
