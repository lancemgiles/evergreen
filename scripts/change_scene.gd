extends Area2D

@export var next_level: PackedScene

func _ready():
	$UI/Menu.visible = false
	
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
	get_tree().change_scene_to_packed(next_level)
	var path = next_level.resource_path
	var scene_name = path.get_file().split(".")[0]
	Global.current_scene_name = scene_name
