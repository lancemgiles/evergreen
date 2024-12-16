extends CharacterBody2D

#player movement variables
@export var speed = 200
@export var gravity = 600
@export var jump_height = -300

#movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	#applies movement
	move_and_slide()
	player_animations() 
	
func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("right") -  Input.get_action_strength("left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed
	
func player_animations():
	if Input.is_action_pressed("left") && Global.is_jumping == false:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("run")
	if Input.is_action_pressed("right") && Global.is_jumping == false:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("run")
		
	if !Input.is_anything_pressed():
		$AnimatedSprite2D.play("idle")
		
func _input(event):
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_height
		$AnimatedSprite2D.play("jump")
		Global.is_jumping = true
	else:
		Global.is_jumping = false
