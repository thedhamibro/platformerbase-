extends CharacterBody2D

signal damage
signal update_hearts

@export var SPEED = 130.0
@export var JUMP_VELOCITY = -300.0
const ATTACK_COOLDOWN = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
var is_attacking = false
var attack_timer = 0.5
var attack_combo = 0
var is_defending = false
var last_checkpoint_position = Vector2()

func _physics_process(delta):
	if Global.lives == 0:
		get_tree().reload_current_scene()
		Global.lives = Global.max_lives
		
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if direction and not is_attacking and not is_defending:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor():
		if Input.is_action_just_pressed("attack") and not is_defending:
			if not is_attacking:
				await attack()
			else:
				if attack_combo < 2:
					attack_combo += 1
					await attack()
		elif is_attacking:
			attack_timer -= delta
			if attack_timer <= 0:
				is_attacking = false
				attack_combo = 0
		elif Input.is_action_just_pressed("defend") and not is_defending:
			defend()
		elif is_defending:
			animated_sprite.play("defend")
		elif direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if is_defending and not Input.is_action_pressed("defend"):
		stop_defending()

	move_and_slide()

func attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	match attack_combo:
		0:
			animated_sprite.play("attack1")
		1:
			animated_sprite.play("attack2")
	await animated_sprite.animation_finished
	is_attacking = false
	attack_combo = 0

func defend() -> void:
	is_defending = true
	animated_sprite.play("defend")

func stop_defending() -> void:
	is_defending = false
	if is_on_floor():
		animated_sprite.play("idle")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2"]:
		pass


func _on_damage() -> void:
	Global.lives -= 1
	respawn()
	
func _on_player_reached_checkpoint(position) -> void:
	print(position)
	last_checkpoint_position = position

func respawn(): 
	self.position = last_checkpoint_position
	emit_signal("update_hearts")
	
