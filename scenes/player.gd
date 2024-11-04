extends CharacterBody2D

class_name player

signal damage
signal update_hearts

# Movement Variables
@export var SPEED = 130.0
@export var JUMP_VELOCITY = -300.0
const ATTACK_COOLDOWN = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_checkpoint_position = Vector2()
@onready var damage_zone: Area2D = $"Damage Zone"

# Attack Variables
var is_attacking = false  # Starts as false
var attack_timer = 0.5
var hitDamage = 0
var attackType

# Node References
@onready var animated_sprite = $AnimatedSprite2D
var playerDamageArea

# Physics Process
func _physics_process(delta):
	handle_movement(delta)
	handle_animations()
	move_and_slide()
	check_hitbox()
	Global.playerDamageZone = damage_zone

# Movement Handling
func handle_movement(delta):
	if Global.lives == 0:
		get_tree().reload_current_scene()
		Global.lives = Global.max_lives

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_attacking:
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction > 0 and !is_attacking:
		animated_sprite.flip_h = false
		damage_zone.scale.x = 1
	elif direction < 0 and !is_attacking:
		animated_sprite.flip_h = true
		damage_zone.scale.x = -1

	if direction and not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# Animation Handling
func handle_animations():
	var direction = Input.get_axis("left", "right")
	if is_on_floor():
		if Input.is_action_just_pressed("attack_left") and !is_attacking:
			await attack_left()
			attackType = 1
		elif Input.is_action_just_pressed("attack_right") and !is_attacking:
			await attack_right()
			attackType = 2
		elif direction == 0 and !is_attacking:
			animated_sprite.play("idle")
		elif !is_attacking:
			animated_sprite.play("run")
	elif !is_attacking:
		animated_sprite.play("jump")

# Attack Handling
func attack_left() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	animated_sprite.play("attack1")  # Replace with your left attack animation
	await get_tree().create_timer(0.5).timeout  # Adjust this timer to match animation length
	is_attacking = false

func attack_right() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	animated_sprite.play("attack2")  # Replace with your right attack animation
	await get_tree().create_timer(0.5).timeout  # Adjust this timer to match animation length
	is_attacking = false

# Check Hitbox
func check_hitbox():
	var hitbox_areas = $Hitbox.get_overlapping_areas()
	if hitbox_areas and is_attacking:
		for hitbox in hitbox_areas:
			if hitbox.get_parent() is Enemy:
				hitbox.get_parent().take_damage(hitDamage)

# Signal Handlers
func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2"]:
		pass

func _on_damage() -> void:
	Global.lives -= 1
	respawn()

func _on_player_reached_checkpoint(position) -> void:
	print(position)
	last_checkpoint_position = position

# Respawn Function
func respawn():
	self.position = last_checkpoint_position
	emit_signal("update_hearts")

func handle_attack_damage(body_name):
	if body_name == "Enemy" and is_attacking:
		if attackType == 1:
			hitDamage = 10
		elif attackType == 2:
			hitDamage = 20

# Damage Zone Signal Handler
func _on_damage_zone_body_entered(body: Node2D) -> void:
	handle_attack_damage(body.name)
