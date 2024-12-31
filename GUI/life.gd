extends ColorRect

@onready var label = $Label

func update_lives(lives, max_lives):
	label.text = str(lives)
	Global.lives = lives
	Global.max_lives = max_lives
