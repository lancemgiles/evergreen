extends CharacterBody2D

#player movement variables
@export var speed = 200
@export var gravity = 600
@export var jump_height = -300

# 1 is right, -1 is left, 0 is none
var last_direction = 0
var current_direction = 0

signal update_lives(lives, max_lives)
var max_lives = 3
@export var lives = 3
var is_hurt = false

signal update_score(score)
var score = 0
var level_start_time = Time.get_ticks_msec()

@onready var level = $UI/Level/Value

func _ready():
	current_direction = 1
	update_lives.connect($UI/Health.update_lives)
	update_score.connect($UI/Score.update_score)
	$UI/Health/Label.text = str(lives)
	update_level_label()

func _physics_process(delta):
	velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()
	player_animations()
	sooth()
	
func score_up(count):
	score += count
	update_score.emit(score)
	
func score_down(count):
	if score >= count:
		score -= count
	elif score <= count:
		score = 0
	update_score.emit(score)

func sooth():
	var current_anime = $AnimatedSprite2D.get_animation()
	if current_anime == "sooth":
		$SoothCast2D.enabled = true
		if $SoothCast2D.is_colliding():
			var target = $SoothCast2D.get_collider(0)
			if target != null && target.is_in_group("Enemies"):
				if target.current_state == target.State.ANGRY:
					target.current_state = target.State.HAPPY
					score_up(100)
	
func _process(_delta):
	if velocity.x > 0: # Moving right
		current_direction = 1
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0: # Moving left
		current_direction = -1
		$AnimatedSprite2D.flip_h = true
	update_time_and_label()
	
func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("right") -  Input.get_action_strength("left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed
	
func player_animations():
	if is_on_floor():
		if Input.is_action_pressed("left") && Global.is_jumping == false:
			
			$AnimatedSprite2D.play("walk")
		if Input.is_action_pressed("right") && Global.is_jumping == false:
			
			$AnimatedSprite2D.play("walk")
		if !Input.is_anything_pressed():
			$AnimatedSprite2D.play("idle")
		
func _input(event):
	if Input.is_action_just_pressed("sooth"):
		Global.is_soothing = true
		$AnimatedSprite2D.play("sooth")
		$SoothCast2D.enabled = true
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_height
		$AnimatedSprite2D.play("jump")
		Global.is_jumping = true
	else:
		Global.is_jumping = false
		Global.is_soothing = false
		$SoothCast2D.enabled = false

func take_damage():
	if lives > 0:
		lives = lives - 1
		update_lives.emit(lives, max_lives)
		$AnimatedSprite2D.play("damage")
		set_physics_process(false)
		$Timer.start()
		is_hurt = true
		score_down(50)
	if lives <= 0:
		$AnimatedSprite2D.play("death")
	

func _on_animated_sprite_2d_animation_finished():
	set_physics_process(true)
	$SoothCast2D.enabled = false
	is_hurt = false


	if $AnimatedSprite2D.animation == "death":
		print("death")
		get_tree().paused = true
		$GameOver/Menu.visible = true
		$AnimationPlayer.play("ui_visibility")
		$UI.visible = false
		final_score_and_time()
		$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$GameOver/Menu/Container/Score/Value.text = str(Global.final_score)
	
func add_pickup(pickup):
	if pickup == Global.Pickups.HEALTH:
		score_up(50)
		if lives < max_lives:
			lives += 1
			update_lives.emit(lives, max_lives)
			
	if pickup == Global.Pickups.SCORE:
		if pickup == Global.Pickups.SCORE:
			score_up(100)
			
func final_score_and_time():
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0
	var round_time = str(roundf(time_taken)) + " seconds"
	
	Global.final_score = score
	Global.final_time = round_time

func _on_timer_timeout() -> void:
	set_physics_process(true)
	
func update_time_and_label():
	var time_passed = (Time.get_ticks_msec() - level_start_time) / 1000.0
	$UI/Time/Label.text = str(round(time_passed)) + "s"
	
func update_level_label():
	var current_level = Global.get_current_level_number()
	if current_level != -1:
		level.text = " " + str(current_level)
	else:
		level.text = "???"

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	$GameOver/Menu.visible = false
	get_tree().reload_current_scene()
