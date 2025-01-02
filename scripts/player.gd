extends CharacterBody2D

enum State {MENU, SOOTHING, IDLE, WALKING, FLOATING}
var state : State

var speed = 175
var gravity = 600
var jump_height = -300

@export var coyote_frames = 6 # adjusting this can allow double jumps
var coyote = false
var last_floor = false

# 1 is right, -1 is left, 0 is none
var last_direction = 0
var current_direction = 0

signal update_health(health, max_health)
var max_health = 3
var health = 3

signal update_lives(lives, max_lives)
var max_lives = 3
var lives = 2

signal update_score(score)
var score = 0
var level_start_score = 0

@onready var level = $UI/Level/Value
var level_start_time = Time.get_ticks_msec()

var checkpoint_manager

@onready var current_level = Global.get_current_level_number()

func _ready():
	current_direction = 1
	update_health.connect($UI/Health.update_health)
	update_score.connect($UI/Score.update_score)
	update_lives.connect($UI/Life.update_lives)
	update_health.emit(Global.health, Global.max_health)
	$UI/Health/Label.text = str(health)
	$UI/Life/Label.text = str(lives)
	state = State.IDLE
	
	checkpoint_manager = get_parent().get_node("CheckpointManager")
	
	await get_tree().create_timer(0.2).timeout
	update_level_label()
	sync_stats_from_global()
	level_start_score = score
	if BackgroundMusic.is_playing() == false:
		BackgroundMusic.play()
		
	$CoyoteTimer.wait_time = coyote_frames / 60.0

func _physics_process(delta):
	velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()
	player_animations()
	sooth()
	terrain_damage()

	if !is_on_floor() and last_floor and !Global.is_jumping:
		coyote = true
		$CoyoteTimer.start()

	last_floor = is_on_floor()

func _process(_delta):
	if velocity.x > 0: # Moving right
		current_direction = 1
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0: # Moving left
		current_direction = -1
		$AnimatedSprite2D.flip_h = true
	update_time_and_label()
	
	match state:
		State.MENU:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		State.IDLE, State.WALKING, State.SOOTHING, State.FLOATING:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if Input.is_action_pressed("pause"):
		state = State.MENU
		$PauseMenu.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("sooth"):
		state = State.SOOTHING
		Global.is_soothing = true
		$AnimatedSprite2D.play("sooth")
		$Audio/SoothSound.play()
	if event.is_action_pressed("jump") and (is_on_floor() or coyote):
		state = State.FLOATING
		velocity.y = jump_height
		$AnimatedSprite2D.play("jump")
		Global.is_jumping = true
		$Audio/FloatSound.play()
		$Effects/JumpParticles.emitting = true
	if event.is_action_pressed("down") and is_on_floor():
		self.position = Vector2(self.position.x, self.position.y + 3)
	else:
		Global.is_jumping = false
		Global.is_soothing = false
		$Soother.set_deferred("monitoring", false)

func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("right") -  Input.get_action_strength("left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

func player_animations():
	if is_on_floor():
		if Input.is_action_pressed("left") && Global.is_jumping == false:
			state = State.WALKING
			$AnimatedSprite2D.play("walk")
		if Input.is_action_pressed("right") && Global.is_jumping == false:
			state = State.WALKING
			$AnimatedSprite2D.play("walk")
		if $AnimatedSprite2D.animation == "sooth":
			await $AnimatedSprite2D.animation_finished
			state = State.IDLE
			$AnimatedSprite2D.play("idle")
		if !Input.is_anything_pressed():
			state = State.IDLE
			$AnimatedSprite2D.play("idle")

func sooth():
	if state == State.SOOTHING:
		$Soother.set_deferred("monitoring", true)


func take_damage(damage_health, damage_score):
	set_physics_process(false)
	$Timer.start()
	score_down(damage_score)
	$Audio/DamageSound.play()
	if health > 0:
		if damage_health > health:
			damage_health = health
		health = health - damage_health
		update_health.emit(health, max_health)
		$AnimatedSprite2D.play("damage")
		Global.health = health
	if health <= 0:
		$AnimatedSprite2D.play("death")

func terrain_damage():
	if $HurtCast.is_colliding():
		var y_offset = 10
		var x_knockback = 20
		var target = $HurtCast.get_collider(0)
		if target != null && target.is_in_group("Danger"):
			take_damage(1, 0)
			var collision_x = $HurtCast.get_collision_point(0).x
			var collision_y = $HurtCast.get_collision_point(0).y - y_offset
			if collision_x >= position.x:
					position.x -= x_knockback
			elif collision_x < position.x:
				position.x += x_knockback
			if collision_y > position.y:
				velocity.y = jump_height

func lose_life():
	lives -= 1
	update_lives.emit(lives, max_lives)
	score_down(100)
	if lives >= 0:
		respawn()
	else:
		get_tree().paused = true
		$GameOver.visible = true
		$AnimationPlayer.play("ui_visibility")
		$UI.visible = false
		final_score_and_time()
		
		state = State.MENU
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$GameOver/Menu/Container/Score/Value.text = str(Global.final_score)
		score = level_start_score
		BackgroundMusic.loop = false

func respawn():
	state = State.IDLE
	position = checkpoint_manager.last_location
	
	if health <= 0:
		health += 1
		update_health.emit(health, max_health)
		Global.health = health

func score_up(count):
	score += count
	update_score.emit(score)
	
func score_down(count):
	if score >= count:
		score -= count
	elif score <= count:
		score = 0
	update_score.emit(score)

func add_pickup(pickup):
	if pickup == Global.Pickups.HEALTH:
		score_up(50)
		$Audio/HealthSound.play()
		if health < max_health:
			health += 1
			update_health.emit(health, max_health)
			
	if pickup == Global.Pickups.SCORE:
		if pickup == Global.Pickups.SCORE:
			score_up(100)
			$Audio/ScoreSound.play()
			
	if pickup == Global.Pickups.LIFE:
		score_up(100)
		$Audio/LifeSound.play()
		if lives < max_lives:
			lives += 1
			update_lives.emit(lives, max_lives)
			

func update_time_and_label():
	var time_passed = (Time.get_ticks_msec() - level_start_time) / 1000.0
	$UI/Time/Label.text = str(round(time_passed)) + "s"
	
func update_level_label():
	current_level = Global.get_current_level_number()
	if current_level != -1:
		level.text = " " + str(current_level)
	else:
		level.text = "???"

func final_score_and_time():
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0
	var round_time = str(roundf(time_taken)) + " seconds"
	
	Global.final_score = score
	Global.final_time = round_time

func _on_animated_sprite_2d_animation_finished():
	set_physics_process(true)
	$Soother.set_deferred("monitoring", false)

	if $AnimatedSprite2D.animation == "death":
		lose_life()

func _on_timer_timeout() -> void:
	set_physics_process(true)	

func _on_retry_button_pressed() -> void:
	state = State.IDLE
	$GameOver/Menu.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()
	update_lives.emit(2, max_lives)
	update_score.emit(level_start_score)
	update_health.emit(max_health, max_health)
	sync_stats_from_global()

func _on_resume_button_pressed() -> void:
	state = State.IDLE
	get_tree().paused = false
	$PauseMenu.visible = false

func _on_quit_button_pressed() -> void:
	Global.new_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func sync_stats_from_global():
	health = Global.health
	max_health = Global.max_health
	update_health.emit(health, max_health)
	
	lives = Global.lives
	max_lives = Global.max_lives
	update_lives.emit(lives, max_lives)
	
	score = Global.score
	update_score.emit(score)

func _on_coyote_timer_timeout() -> void:
	coyote = false

func _on_soother_area_entered(area: Area2D) -> void:
	state = State.IDLE
	if area.name == "HurtBox":
		var target = area.get_parent()
		target.sooth_step()
