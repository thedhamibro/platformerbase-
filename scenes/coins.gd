extends AnimatedSprite2D

@onready var player: CharacterBody2D = $"../player"
@onready var node: Node = $"../Node"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name ==  "player":
		node.coins += 1
		node.score += 100
		print(node.coins)
		print(node.score)
		queue_free()
