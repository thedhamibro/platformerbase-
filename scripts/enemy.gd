extends RigidBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../player"
@onready var collision_shape = $CollisionShape2D
@onready var area: CollisionShape2D = $Area2D/CollisionShape2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		animated_sprite.play("attack")
		
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		print("kill enemy")
	
#area.position += Vector2(-1, 0)
#if collision_shape: 
	#collision_shape.position += Vector2(-9, 2)
