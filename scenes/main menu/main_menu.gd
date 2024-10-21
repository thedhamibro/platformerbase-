class_name MainMenu
extends Control


@onready var start_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/start_button as Button 
@onready var exit_buuton: Button = $MarginContainer/HBoxContainer/VBoxContainer/exit_buuton as Button
@export var start_level = preload("res://scenes/main.tscn") as PackedScene


func _ready():
	start_button.button_down.connect(on_start_pressed)
	exit_buuton.button_down.connect(on_exit_pressed)

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)


func on_exit_pressed() -> void:
	get_tree().quit()
	
