extends CanvasLayer

const HEART = preload("res://scripts/heart.tscn")
@onready var hearts: HBoxContainer = $Hearts/Hearts

func _ready() -> void:
	var lives = Global.lives
	for i in range(lives):
		instantiate_heart()


func instantiate_heart():
	var heart = HEART.instantiate()
	hearts.add_child(heart)
