class_name WalkingBouncyEnemy extends CharacterBody2D

@export_group("Enemy Properties")
@export var speed = 50
@export var distance = 100
var gravity = 1600
var knockback_strength = 20
@export var bouncy = true
var bounciness = 1.5
var damage_health = 1
var damage_score = 50

var guard_timer : Timer
var guard_shift = 4

@onready var start_x = position.x
@onready var target_x = position.x + distance

enum PowerLevel {ZERO, ONE, TWO}
@export var power_level := PowerLevel.ZERO

enum Mood {ANGRY, HAPPY, MIDDLE}
var current_mood := Mood.ANGRY

enum Role {GUARD, PATROL}
@export var role := Role.PATROL

# 1 is right, -1 is left, 0 is none
var current_direction = 0

func _ready() -> void:
	current_direction = 1
	guard_timer = Timer.new()
	guard_timer.autostart = true
	guard_timer.wait_time = guard_shift
	guard_timer.timeout.connect(_on_guard_timer_timeout)
	self.add_child(guard_timer)
	
	match power_level:
		PowerLevel.ZERO:
			damage_health = 1
			bounciness = 1.5
			knockback_strength = 18.0
		PowerLevel.ONE:
			damage_health = 1
			bounciness = 2
			knockback_strength = 25.0
		PowerLevel.TWO:
			damage_health = 2
			bounciness = 3.25
			knockback_strength = 30.0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	match current_mood:
		Mood.ANGRY:
			$AnimatedSprite2D.play("angry")
			bouncy = false
			if has_node("AngryParticles"):
				$AngryParticles.emitting = true
		Mood.MIDDLE:
			$AnimatedSprite2D.play("middle")
			bouncy = false
			$HitBox/CollisionAngry.set_deferred("disabled", true)
			if $HitBox.has_node("CollisionMid"):
				$HitBox/CollisionMid.set_deferred("disabled", false)
			if has_node("AngryParticles"):
				$AngryParticles.emitting = false
		Mood.HAPPY:
			$AnimatedSprite2D.play("happy")
			bouncy = true
			if $HitBox.has_node("CollisionMid"):
				$HitBox/CollisionMid.set_deferred("disabled", true)
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
	$HitBox.set_collision_mask_value(2, true)

func _on_bounce_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if bouncy:
			body.velocity.y = -sqrt(2 * body.jump_height * body.gravity) * bounciness
		if current_mood != Mood.HAPPY:
			body.velocity.y = -sqrt(2 * knockback_strength * body.gravity)

func _on_hitbox_body_entered(body: Node2D) -> void:
	match current_mood:
		Mood.ANGRY, Mood.MIDDLE:
			if body.name == "Player":
				body.take_damage(damage_health, damage_score)
				var direction = global_position.direction_to(body.global_position)
				var force = (direction* 100.0) * knockback_strength
				body.knockback = force
				$HitBox.set_collision_mask_value(2, false)
				$Timer.start(0.8)

func sooth_step():
	$HurtTimer.start(0.8)
	$HurtBox.set_collision_mask_value(8, false)
	if current_mood == Mood.ANGRY:
		match power_level:
			PowerLevel.ZERO, PowerLevel.ONE:
				current_mood = Mood.HAPPY
			PowerLevel.TWO:
				current_mood = Mood.MIDDLE
	elif current_mood == Mood.MIDDLE:
		current_mood = Mood.HAPPY

func _on_hurt_timer_timeout() -> void:
	$HurtBox.set_collision_mask_value(2, true)

func _on_guard_timer_timeout():
	if role == Role.GUARD:
		if $AnimatedSprite2D.flip_h == true:
			$AnimatedSprite2D.flip_h = false
		elif $AnimatedSprite2D.flip_h == false:
			$AnimatedSprite2D.flip_h = true
		guard_timer.start(guard_shift)
