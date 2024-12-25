extends StaticBody2D

@export var bounciness = 2

func _ready():
	$AnimatedSprite2D.play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y = body.jump_height * bounciness
