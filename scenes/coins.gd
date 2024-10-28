extends AnimatedSprite2D

@onready var node = $GameManager
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('PLAYER'):
		node.coins += 1
		node.score +=100
		queue_free()
