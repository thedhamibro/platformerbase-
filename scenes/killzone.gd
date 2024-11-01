extends Area2D

@onready var player: CharacterBody2D = $"../player"

@onready var timer: Timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	_on_player_damage()
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_player_damage() -> void:
	player._on_damage()
