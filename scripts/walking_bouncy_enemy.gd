class_name WalkingBouncyEnemy extends CharacterBody2D

@export_group("Enemy Properties")
@export var speed = 50
@export var distance = 100
var gravity = 1600
var knockback_force = 20
@export var bouncy = true
var bounciness = 1.5
var damage_health = 1
var damage_score = 50

@onready var start_x = position.x
@onready var target_x = position.x + distance

enum PowerLevel {ONE, TWO}
@export var power_level := PowerLevel.ONE

enum Mood {ANGRY, HAPPY, MIDDLE}
var current_mood := Mood.ANGRY

enum Role {GUARD, PATROL}
@export var role := Role.PATROL

# 1 is right, -1 is left, 0 is none
var current_direction = 0

func _ready() -> void:
	current_direction = 1
	match role:
		Role.GUARD:
			$AnimatedSprite2D.flip_h = true
	
	match power_level:
		PowerLevel.ONE:
			damage_health = 1
			bounciness = 1.5
			knockback_force = 20
		PowerLevel.TWO:
			damage_health = 2
			bounciness = 3.25
			knockback_force = 64

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	match current_mood:
		Mood.ANGRY:
			$AnimatedSprite2D.play("angry")
			if power_level == PowerLevel.ONE:
				bouncy = true
			else:
				bouncy = false
			if has_node("AngryParticles"):
				$AngryParticles.emitting = true
		Mood.MIDDLE:
			$AnimatedSprite2D.play("middle")
			bouncy = false
			$Hitbox/CollisionAngry.disabled = true
			if $Hitbox.has_node("CollisionMid"):
				$Hitbox/CollisionMid.disabled = false
			if has_node("AngryParticles"):
				$AngryParticles.emitting = false
		Mood.HAPPY:
			$AnimatedSprite2D.play("happy")
			bouncy = true
			if $Hitbox.has_node("CollisionMid"):
				$Hitbox/CollisionMid.disabled = true
			if has_node("AngryParticles"):
				$AngryParticles.emitting = false
	move_and_slide()

func _process(delta):
	match role:
		Role.PATROL:
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

func _on_timer_timeout() -> void:
	$Hitbox.collision_mask = 2

func _on_bounce_body_entered(body: Node2D) -> void:
	if bouncy and body.is_in_group("Player"):
		body.velocity.y = body.jump_height * bounciness

func _on_hitbox_body_entered(body: Node2D) -> void:
	match current_mood:
		Mood.ANGRY, Mood.MIDDLE:
			if body.name == "Player":
				body.take_damage(damage_health, damage_score)
				if current_direction == 1:
					body.position.x += knockback_force
				elif current_direction == -1:
					body.position.x -= knockback_force
				$Hitbox.collision_mask = 9
				$Timer.start(0.8)

func sooth_step():
	$HurtTimer.start(0.8)
	$HurtBox.collision_mask = 9
	if power_level == PowerLevel.ONE and current_mood == Mood.ANGRY:
		current_mood = Mood.HAPPY
	elif power_level == PowerLevel.TWO and current_mood == Mood.ANGRY:
		current_mood = Mood.MIDDLE
	elif current_mood == Mood.MIDDLE:
		current_mood = Mood.HAPPY

func _on_hurt_timer_timeout() -> void:
	$HurtBox.collision_mask = 2
	$Hurtbox.visible = true

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "Soother":
		$HurtTimer.start(0.8)
		$HurtBox.collision_mask = 9
