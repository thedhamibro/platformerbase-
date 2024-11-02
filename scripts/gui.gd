extends CanvasLayer

const HEART = preload("res://scripts/heart.tscn")
@onready var hearts: HBoxContainer = $Hearts/Hearts

func _ready() -> void:
	_on_player_update_hearts()

func instantiate_heart(heart_scene):
	var heart = heart_scene.instantiate()
	hearts.add_child(heart)
	return heart

func _on_player_update_hearts() -> void:
	# Remove all existing heart nodes
	for child in hearts.get_children():
		hearts.remove_child(child)
		child.queue_free()

	var lives = Global.lives
	var max_lives = Global.max_lives

	for i in range(lives):
		instantiate_heart(HEART)

	for i in range(max_lives - lives):
		var empty_heart = instantiate_heart(HEART)
		empty_heart.get_node("Heart").visible = false
