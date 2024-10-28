extends Area2D

signal transition_to_next_level

@onready var player: CharacterBody2D = $"../player"
@onready var area_2d: Area2D = $"."

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		emit_signal("transition_to_next_level")
		#print("Player has entered the door area.")

# Function to handle any extra behavior for transition if needed
func _on_transition_to_next_level() -> void:
	#print("Transition signal received.")
	pass
