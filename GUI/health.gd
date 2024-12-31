extends ColorRect

@onready var label = $Label

func update_health(health, max_health):
	label.text = str(health)
	Global.health = health
	Global.max_health = max_health
