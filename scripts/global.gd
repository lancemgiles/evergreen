extends Node

const SAVE_PATH = "user://savegame.save"

var current_scene_name

enum Pickups {HEALTH, SCORE, LIFE}

var is_jumping = false
var is_soothing = false

var health = 3
var max_health = 3

var lives = 2
var max_lives = 3
var score = 0

var final_score
var final_time

func _ready():
	var scene_name = get_tree().get_current_scene().name
	current_scene_name = clean_scene_name(scene_name)

func get_current_level_number():	
	if current_scene_name == "MainMenu":
		return 1
	elif current_scene_name.begins_with("Level_"):
		var level_number = current_scene_name.get_slice("_", 1).to_int()
		return level_number
	else:
		print(current_scene_name)
		return -1

func save_game():
	var save_file = ConfigFile.new()
	save_file.set_value("level", "current_level", "res://scenes/" + Global.current_scene_name + ".tscn")
	
	save_file.set_value("health", "health", health)
	save_file.set_value("health", "max_health", max_health)
	
	save_file.set_value("lives", "lives", lives)
	save_file.set_value("lives", "max_lives", max_lives)
	
	save_file.set_value("score", "score", score)
	
	var err = save_file.save(SAVE_PATH)
	if err != OK:
		print("An error occurred while saving the game.")
	else:
		print("Saving game.")

func load_game():
	var save_file = ConfigFile.new()
	var err = save_file.load(SAVE_PATH)

	if err == OK:
		print("Loading game.")
		var saved_level = save_file.get_value("level", "current_level", "res://scenes/Level_1.tscn")
		var new_scene_resource = load(saved_level)
		var new_scene = new_scene_resource.instantiate()
		get_tree().get_root().add_child(new_scene)
		get_tree().current_scene = new_scene
		current_scene_name = get_tree().get_current_scene().name
		clean_scene_name(current_scene_name)
		
		health = save_file.get_value("health", "health", "3")
		max_health = save_file.get_value("health", "max_health", "3")
		
		lives = save_file.get_value("lives", "lives", "2")
		max_lives = save_file.get_value("lives", "max_lives", "3")
		
		score = save_file.get_value("score", "score", "0")
		
		get_tree().paused = false
	else:
		print("An error occurred while loading the game.")

func clean_scene_name(scene_name):
	var at_position = scene_name.find("@")
	if at_position != -1:
		return scene_name.substr(0, at_position)
	else:
		return scene_name

func new_game():
	health = 3
	max_health = 3
	lives = 2
	max_lives = 3
	score = 0
