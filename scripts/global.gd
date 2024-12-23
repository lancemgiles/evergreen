extends Node

var current_scene_name

enum Pickups {HEALTH, SCORE}

var is_jumping = false
var is_soothing = false

var final_score
var final_time

func _ready():
	current_scene_name = get_tree().get_current_scene().name

func get_current_level_number():
	if current_scene_name == "Main":
		return 1
	elif current_scene_name.begins_with("Main_"):
		var level_number = current_scene_name.get_slice("_", 1).to_int()
		return level_number
	else:
		print(current_scene_name)
		return -1
