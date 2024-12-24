extends ColorRect

@onready var label = $Label

func update_health(health, _max_health):
	label.text = str(health)
