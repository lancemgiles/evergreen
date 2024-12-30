extends Area2D

@export var next_level_number : String
var next_level_path = "res://scenes/Level_2.tscn"
var shape

func _ready():
	$UI/Menu.visible = false
	next_level_path = "res://scenes/Level_" + str(next_level_number) + ".tscn"
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().paused = true
		$UI/Menu.visible = true
		$AnimationPlayer.play("ui_visibility")
		body.get_node("UI").visible = false
		body.final_score_and_time()
		$UI/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$UI/Menu/Container/Score/Value.text = str(Global.final_score)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().change_scene_to_file(next_level_path)
	var scene_name = "Level_" + str(next_level_number)
	Global.current_scene_name = scene_name

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_save_continue_button_2_pressed() -> void:
	Global.save_game()
	_on_continue_button_pressed()
