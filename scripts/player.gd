extends CharacterBody2D

enum State {MENU, SOOTHING, IDLE, WALKING, FLOATING, HURT, DEAD}
var state : State

var speed = 175
var gravity = 600
var jump_height = 75 #height in pixels, about nine 8x8 tiles
var dying = false
signal sooth_landed(area)
#var sooth_cooling_down = false

@export var coyote_frames = 6 # adjusting this can allow double jumps
var coyote = false
var last_floor = false

# 1 is right, -1 is left, 0 is none
var last_direction = 0
var current_direction = 0
var knockback = Vector2.ZERO

signal update_health(health, max_health)
var max_health = 3
var health = 3

signal died

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
	sooth_landed.connect(_on_sooth_landed)
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
	#floor_stop_on_slope = false

func _physics_process(delta):
	player_movement(delta)
	move_and_slide()
	player_animations()
	terrain_damage()
	sooth()

	if !is_on_floor() and last_floor and !Global.is_jumping:
		coyote = true
		print("coyote time")
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
		State.IDLE, State.WALKING, State.SOOTHING, State.FLOATING, State.HURT, State.DEAD:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if state == State.DEAD:
		return 0.0
	if Input.is_action_pressed("pause"):
		state = State.MENU
		$PauseMenu.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("sooth"):
		if state != State.SOOTHING:
			print("sooth press")
			$Soother.set_collision_mask_value(8, true)
			#sooth_cooling_down = true
			$SoothSprite.visible = true
			$AnimatedSprite2D.visible = false
			if current_direction == -1:
				$SoothSprite.flip_h = true
			if current_direction == 1:
				$SoothSprite.flip_h = false
			$AnimationPlayer.play("sooth")
			state = State.SOOTHING
			$Audio/SoothSound.play()
	if event.is_action_pressed("jump") and (is_on_floor() or coyote):
		velocity.y = -sqrt(2 * gravity * jump_height)
		$AnimatedSprite2D.play("jump")
		state = State.FLOATING
		Global.is_jumping = true
		$Audio/FloatSound.play()
		$Effects/JumpParticles.emitting = true
	if event.is_action_pressed("down") and is_on_floor():
		self.position = Vector2(self.position.x, self.position.y + 3)
	else:
		Global.is_jumping = false
		Global.is_soothing = false
		$Soother.set_collision_mask_value(8, false)

func player_movement(delta):
	var horizontal_input = Input.get_axis("left", "right")
	velocity.x = horizontal_input * speed + knockback.x
	velocity.y += gravity * delta
	if state != State.HURT:
		knockback = Vector2.ZERO

func player_animations():
	if is_on_floor():
		if Input.is_action_pressed("left") && Global.is_jumping == false:
			$AnimatedSprite2D.play("walk")
			state = State.WALKING
		if Input.is_action_pressed("right") && Global.is_jumping == false:
			$AnimatedSprite2D.play("walk")
			state = State.WALKING
		if !Input.is_anything_pressed() and !dying:
			$AnimatedSprite2D.play("idle")
			state = State.IDLE

func sooth():
	if state == State.SOOTHING:
		$Soother.set_collision_mask_value(8, true)

func take_damage(damage_health, damage_score):
	set_physics_process(false)
	$DamageTimer.start()
	score_down(damage_score)
	$Audio/DamageSound.play()
	if health > 0:
		health = health - damage_health
		if health < 0: health = 0
		update_health.emit(health, max_health)
		$AnimatedSprite2D.play("damage")
		state = State.HURT
	if health <= 0:
		dying = true
		$AnimatedSprite2D.visible = false
		$SoothSprite.visible = false
		$DeathSprite.visible = true
		$AnimationPlayer.play("death")
		state = State.DEAD

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
		state = State.MENU
		$UI.visible = false
		final_score_and_time()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$GameOver/Menu/Container/Score/Value.text = str(Global.final_score)
		score = level_start_score
		BackgroundMusic.loop = false

func respawn():
	$AnimatedSprite2D.play("idle")
	state = State.IDLE
	position = checkpoint_manager.last_location
	
	if health <= 0:
		health += 1
		update_health.emit(health, max_health)

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
	print("soother entered")
	if area.name == "HurtBox" and $AnimationPlayer.current_animation == "sooth":
		sooth_landed.emit(area)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		dying = false
		$AnimatedSprite2D.visible = true
		$DeathSprite.visible = false
		# state = State.IDLE #see if this is allowing player to leave death state
	if anim_name == "sooth":
		$Soother.set_collision_mask_value(8, false)
		#state = State.IDLE
		Global.is_soothing = false
		$SoothSprite.visible = false
		$AnimatedSprite2D.visible = true
		#$AnimatedSprite2D.play("idle")
		
func _on_sooth_landed(area):
	print("sooth landed")
	$Soother.set_collision_mask_value(8, false)
	var target_body = area.get_parent()
	if target_body.current_mood != target_body.Mood.HAPPY:
		target_body.sooth_step()
		score_up(100)


func _on_sooth_timer_timeout() -> void:
	$Soother.set_collision_mask_value(8, false)
	#sooth_cooling_down = false


func _on_damage_timer_timeout() -> void:
	set_physics_process(true)
