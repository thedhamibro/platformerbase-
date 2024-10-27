extends Area2D

signal transition_to_next_level

@onready var player: CharacterBody2D = $"../player"
@onready var area_2d: Area2D = $"."

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("i ate a rabbit")
	if body == player:
		emit_signal("transition_to_next_level")
		print("i ate a rabbit")
