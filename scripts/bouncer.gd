@tool

extends StaticBody2D

enum Version {REGULAR, MEDIUM, SUPER}

@export var version: Version

var bounciness : float

func _ready():
	get_version()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		get_version()
		$AnimatedSprite2D.pause()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y = body.jump_height * bounciness
		
func get_version():
	match version:
		Version.REGULAR:
			bounciness = 2
			$AnimatedSprite2D.play("regular")
		Version.MEDIUM:
			bounciness = 3
			$AnimatedSprite2D.play("medium")
		Version.SUPER:
			bounciness = 4
			$AnimatedSprite2D.play("super")
