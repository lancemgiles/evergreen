extends CanvasLayer

func _on_new_button_pressed() -> void:
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	
	var new_scene = load("res://scenes/Main.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().set_current_scene(new_scene)
	Global.current_scene_name = new_scene.name
	
	get_tree().paused = false

func _on_load_button_pressed() -> void:
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	Global.load_game()
	get_tree().paused = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()
