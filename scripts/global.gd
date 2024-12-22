extends Node

enum Pickups {HEALTH, SCORE}
var is_jumping = false
var current_scene_name
var is_soothing = false

# for new levels
func _ready():
	current_scene_name = get_tree().get_current_scene().name
