extends RigidBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../player"


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		animated_sprite.play("attack")
		
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		print("kill enemy")
		
		
