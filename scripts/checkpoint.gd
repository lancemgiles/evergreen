extends Area2D

var checkpoint_manager

func _ready() -> void:
	checkpoint_manager = get_parent().get_parent().get_node("CheckpointManager")
	$AnimatedSprite2D.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		checkpoint_manager.last_location = $RespawnPoint.global_position
		$SaveParticles.emitting = true
		$SaveSound.play()

func _on_body_exited(_body: Node2D) -> void:
	$SaveParticles.emitting = false
