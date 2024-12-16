extends CharacterBody2D

var player

enum StateX {WAIT_AT_RIGHT, MOVING_LEFT, WAIT_AT_LEFT, MOVING_RIGHT}
var current_state_x = StateX.WAIT_AT_RIGHT

enum StateY {WAIT_AT_BOTTOM, MOVING_UP, WAIT_AT_TOP, MOVING_DOWN}
var current_state_y = StateY.WAIT_AT_BOTTOM

var initial_position_y
var initial_position_x

var progress_y = 0.0
var progress_x = 0.0

@export var movement_x = false
@export var movement_speed_x = 50.0
@export var movement_range_x = 50

@export var wait_time_at_left = 3.0
@export var wait_time_at_right = 3.0

@export var movement_y = true
@export var movement_speed_y = 50.0
@export var movement_range_y = 50

@export var wait_time_at_top = 3.0
@export var wait_time_at_bottom = 3.0

func _ready():
	player = get_parent().get_node("Player")
	
	initial_position_y = position.y
	switch_state(StateY.MOVING_UP)
	
	initial_position_x = position.x
	switch_state(StateX.MOVING_LEFT)
	
func _physics_process(delta):
	if movement_y:
		match current_state_y:
			StateY.MOVING_UP:
				progress_y += delta
				position.y = lerp(initial_position_y, initial_position_y - movement_range_y, progress_y / (movement_range_y / movement_range_y))
				if progress_y >= (movement_range_y / movement_speed_y):
					switch_state(StateY.WAIT_AT_TOP)
					
			StateY.MOVING_DOWN:
				progress_y -= delta
				position.y = lerp(initial_position_y, initial_position_y - movement_range_y, progress_y / (movement_range_y / movement_range_y))
				if progress_y <= 0:
					switch_state(StateY.WAIT_AT_BOTTOM)
	
	if movement_x:
		match current_state_x:
			StateX.MOVING_LEFT:
				progress_x += delta
				position.x = lerp(initial_position_x, initial_position_x - movement_range_x, progress_x / (movement_range_x / movement_range_x))
				if progress_x >= (movement_range_x / movement_speed_x):
					switch_state(StateX.WAIT_AT_LEFT)
					
			StateX.MOVING_RIGHT:
				progress_x -= delta
				position.x = lerp(initial_position_x, initial_position_x - movement_range_x, progress_x / (movement_range_x / movement_range_x))
				if progress_x <= 0:
					switch_state(StateX.WAIT_AT_RIGHT)

func _on_timer_timeout() -> void:
	if movement_y:
		if current_state_y == StateY.WAIT_AT_TOP:
			switch_state(StateY.MOVING_DOWN)
			
		if current_state_y == StateY.WAIT_AT_BOTTOM:
			switch_state(StateY.MOVING_UP)
			
	if movement_x:
		if current_state_x == StateX.WAIT_AT_LEFT:
			switch_state(StateX.MOVING_RIGHT)
			
		if current_state_x == StateX.WAIT_AT_RIGHT:
			switch_state(StateX.MOVING_LEFT)
			
func switch_state(new_state):
	if movement_y:
		current_state_y = new_state
		match new_state:
			StateY.MOVING_UP:
				progress_y = 0.0
				
			StateY.WAIT_AT_TOP:
				$Timer.wait_time  = wait_time_at_top
				$Timer.start()
				
			StateY.WAIT_AT_BOTTOM:
				$Timer.wait_time = wait_time_at_bottom
				$Timer.start()
				
			StateY.MOVING_DOWN:
				progress_y = movement_range_y / movement_speed_y
				
	if movement_x:
		current_state_x = new_state
		match new_state:
			StateX.MOVING_LEFT:
				progress_x = 0.0
				
			StateX.WAIT_AT_LEFT:
				$Timer.wait_time  = wait_time_at_left
				$Timer.start()
				
			StateX.WAIT_AT_RIGHT:
				$Timer.wait_time = wait_time_at_right
				$Timer.start()
				
			StateX.MOVING_RIGHT:
				progress_x = movement_range_x / movement_speed_x
			
func _on_sticky_body_entered(body: Node2D) -> void:
	if movement_x:
		if body.is_in_group("Player"):
			player.velocity.x = velocity.x
