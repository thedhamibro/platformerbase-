extends CharacterBody2D

class_name player

signal damage
signal update_hearts
signal attack

# Movement Variables
@export var SPEED: float = 130.0
@export var JUMP_VELOCITY: float = -300.0
const ATTACK_COOLDOWN: float = 0.5
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_checkpoint_position: Vector2 = Vector2()
@onready var damage_zone: Area2D = $"Damage Zone"  # Ensure the path is correct
var dead: bool =  false

# Attack Variables
var is_attacking = false  # Starts as false
var attack_timer = 0.5
var hitDamage = 0
var attackType

# Node References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox  # Ensure the path is correct
@onready var enemy: Enemy = $"../Enemy"

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
		respawn()
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
	if is_on_floor() and !dead:
		if Input.is_action_just_pressed("attack_left") and not is_attacking:
			attack_left()
		elif Input.is_action_just_pressed("attack_right") and not is_attacking:
			attack_right()
		elif direction == 0 and not is_attacking:
			animated_sprite.play("idle")
		elif !is_attacking:
			animated_sprite.play("run")
	elif !is_attacking:
		animated_sprite.play("jump")
	elif dead:
		animated_sprite.play("death")

# Attack Handling
func attack_left() -> void:
	is_attacking = true
	attackType = 1
	attack_timer = ATTACK_COOLDOWN
	animated_sprite.play("attack1")  # Replace with your left attack animation
	await get_tree().create_timer(0.5).timeout  # Adjust this timer to match animation length
	is_attacking = false

func attack_right() -> void:
	is_attacking = true
	attackType = 2
	attack_timer = ATTACK_COOLDOWN
	animated_sprite.play("attack2")  # Replace with your right attack animation
	await get_tree().create_timer(0.5).timeout  # Adjust this timer to match animation length
	is_attacking = false

# Check Hitbox
func check_hitbox():
	var damage_areas = damage_zone.get_overlapping_areas()
	var body = damage_zone.get_overlapping_bodies()
	if damage_zone and is_attacking:
		for damage_zone in damage_areas:
			if damage_zone.get_parent() is Enemy:
				handle_attack_damage()
				emit_signal("attack", body)
				enemy.take_damage(hitDamage)
				await get_tree().create_timer(0.6).timeout

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

func handle_attack_damage():
	if attackType == 1:
		hitDamage = 30
	elif attackType == 2:
		hitDamage = 40
