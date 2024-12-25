@tool

extends Area2D

@export var pickup : Global.Pickups

#var health_texture = preload("res://assets/Items/sap.png")
#var score_texture = preload("res://assets/Items/token-01.png")
#var life_texture = preload("res://assets/Items/spore.png")
#
#@onready var pickup_texture = get_node("Sprite2D")

func _ready():
	if pickup == Global.Pickups.HEALTH:
			$AnimatedSprite2D.play("health")
	elif pickup == Global.Pickups.SCORE:
			$AnimatedSprite2D.play("score")
	elif pickup == Global.Pickups.LIFE:
		$AnimatedSprite2D.play("life")

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
