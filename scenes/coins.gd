extends AnimatedSprite2D

@onready var player: CharacterBody2D = $"../player"
@onready var node: Node = $"../../GameManager"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name ==  "player":
		node.coins += 1
		node.score += 100
		queue_free()
