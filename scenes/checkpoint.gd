extends Area2D

signal player_reached_checkpoint
@onready var player: CharacterBody2D = $"../../player"

func _ready():
	pass

func _on_body_entered(body):
	if body.name == "player" :
		emit_signal("player_reached_checkpoint", body.position)
