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

enum State {ANGRY, HAPPY}
var current_state = State.ANGRY

# 1 is right, -1 is left, 0 is none
var current_direction = 0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	match current_state:
		State.ANGRY:
			$AnimatedSprite2D.play("blob-angry")
		State.HAPPY:
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

func move_to(current, target, step):
	var new = current
	if new < target:
		new += step
		current_direction = 1
		if new > target:
			new = target
	else:
		new -= step
		current_direction = -1
		if new < target:
			new = target
	return new

func _on_area_2d_body_entered(body: Node2D) -> void:
	if current_state == State.ANGRY:
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
