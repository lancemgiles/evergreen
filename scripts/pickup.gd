@tool

extends Area2D

@export var pickup : Global.Pickups

func _ready():
	if pickup == Global.Pickups.HEALTH:
		$AnimatedSprite2D.play("health")
	elif pickup == Global.Pickups.SCORE:
		$AnimatedSprite2D.play("score")
	elif pickup == Global.Pickups.LIFE:
		$AnimatedSprite2D.play("life")
		$LifeParticles.emitting = true

func _process(_delta):
	if Engine.is_editor_hint():
		if pickup == Global.Pickups.HEALTH:
			$AnimatedSprite2D.animation = "health"
		elif pickup == Global.Pickups.SCORE:
			$AnimatedSprite2D.animation = "score"
		elif pickup == Global.Pickups.LIFE:
			$AnimatedSprite2D.animation = "life"
		$AnimatedSprite2D.pause()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().queue_delete(self)
		body.add_pickup(pickup)
