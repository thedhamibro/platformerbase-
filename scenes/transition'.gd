extends CanvasLayer

signal on_transition_finished

#var current_scene

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door: Area2D = $"./door"

#
#const SCENE_2 = preload("res://scripts/scene2.tscn")
#const SCENE_1 = preload("res://scripts/scene1.tscn")


func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	#current_scene = get_tree().current_scene
	#print("hello")
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_to_black":
		print("aniamtion")
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		print("aniamtion")
		color_rect.visible = false
	
#func _on_transition_finished() -> void:
	#if current_scene == SCENE_1:
		#get_tree().change_scene_to(SCENE_2)
	#else:
		#get_tree().change_scene_to(SCENE_1)
	#
	## Update the current scene reference after switching.
	#current_scene = get_tree().current_scene
		

func _on_door_transition_to_next_level() -> void:
	color_rect.visible = true
	print("hello")
	animation_player.play("fade_to_black")    
