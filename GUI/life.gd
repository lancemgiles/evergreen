extends ColorRect

@onready var label = $Label

func update_lives(lives, _max_lives):
	label.text = str(lives)