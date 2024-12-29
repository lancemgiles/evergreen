extends CharacterBody2D

@export var speed = 100
@export var distance = 100
@export var gravity = 1600
@export var knockback_force = 20
@export var bounciness = 1.5
@export var damage_health = 1
@export var damage_score = 50

@onready var start_x = position.x
@onready var target_x = position.x + distance

enum Mood {ANGRY, HAPPY}
var current_mood = Mood.ANGRY

# 1 is right, -1 is left, 0 is none
var current_direction = 0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	match current_mood:
		Mood.ANGRY:
			$AnimatedSprite2D.play("blob-angry")
		Mood.HAPPY:
			$AnimatedSprite2D.play("blob-happy")
	move_and_slide()

func _process(delta):
	position.x = move_to(position.x, target_x, speed * delta)
	if position.x == target_x:
		if target_x == start_x:
			target_x = position.x + distance
			$AnimatedSprite2D.flip_h = false
		else:
			target_x = start_x
			$AnimatedSprite2D.flip_h = true

func move_to(current_position, target_position, step_size):
	var new_position = current_position
	# target is to the right
	if new_position < target_position:
		new_position += step_size
		current_direction = 1
		if new_position > target_position:
			new_position = target_position
	else:
		# target is to the left
		new_position -= step_size
		current_direction = -1
		if new_position < target_position:
			new_position = target_position
	return new_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if current_mood == Mood.ANGRY:
		if body.name == "Player":
			body.take_damage(damage_health, damage_score)
			if current_direction == 1:
				body.position.x += knockback_force
			elif current_direction == -1:
				body.position.x -= knockback_force
			$Hitbox.collision_mask = 5
			$Timer.start(0.8)

func _on_timer_timeout() -> void:
	$Hitbox.collision_mask = 2

func _on_bounce_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y = body.jump_height * bounciness
