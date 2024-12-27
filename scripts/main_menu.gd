extends CanvasLayer

func _ready():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if BackgroundMusic.is_playing() == false:
		BackgroundMusic.play()

func _on_new_button_pressed() -> void:
	
	set_process(false)
	$Intro.show()
	
	#if Global.get_current_level_number() > 1:
	#get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_load_button_pressed() -> void:
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	Global.load_game()
	#if is_inside_tree():
		#get_tree().paused = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_accept_button_pressed() -> void:
	$Intro.hide()
	get_tree().paused = false
	set_process(true)
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	var new_scene = load("res://scenes/Level_1.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().set_current_scene(new_scene)
	Global.current_scene_name = new_scene.name

func _on_back_button_pressed() -> void:
	$Instructions.hide()

func _on_controls_pressed() -> void:
	$Instructions.show()
