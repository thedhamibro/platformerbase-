class_name MainMenu
extends Control

@onready var start_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/start_button as Button 
@onready var exit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/exit_buuton as Button
@export var start_level = preload("res://scenes/main.tscn") as PackedScene

func _ready() -> void:
	start_button.pressed.connect(self._on_start_pressed)
	exit_button.pressed.connect(self._on_exit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to(start_level)
	print("Hello!")

func _on_exit_pressed() -> void:
	get_tree().quit()


	
	
	
	
