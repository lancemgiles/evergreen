@tool

extends Area2D

@export var pickup : Global.Pickups

var health_texture = preload("res://assets/Items/sap.png")
var score_texture = preload("res://assets/Items/token-01.png")

@onready var pickup_texture = get_node("Sprite2D")

func _ready():
	if pickup == Global.Pickups.HEALTH:
			pickup_texture.set_texture(health_texture)
	elif pickup == Global.Pickups.SCORE:
			pickup_texture.set_texture(score_texture)

func _process(_delta):
	if Engine.is_editor_hint():
		if pickup == Global.Pickups.HEALTH:
			pickup_texture.set_texture(health_texture)
		elif pickup == Global.Pickups.SCORE:
			pickup_texture.set_texture(score_texture)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().queue_delete(self)
		body.add_pickup(pickup)
