extends AnimatableBody2D

func _physics_process(delta: float) -> void:
	mushroom_animations()

func mushroom_animations():
	$AnimatedSprite2D.play("default")
