extends CharacterBody2D

class_name Player

signal damage
signal update_hearts
signal attack

# Movement Variables
@export var SPEED: float = 130.0
@export var JUMP_VELOCITY: float = -300.0
const ATTACK_COOLDOWN: float = 0.5
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_checkpoint_position: Vector2 = Vector2()
var dead: bool = false

# Attack Variables
var is_attacking = false
var attack_applied = false  # Flag to track if damage was applied in the current attack
var attackType
var hitDamage = 0

# Node References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_zone: Area2D = $"Damage Zone"  # Ensure the path is correct

# Physics Process
func _physics_process(delta):
	handle_movement(delta)
	handle_animations()
	move_and_slide()
	check_hitbox()

# Movement Handling
func handle_movement(delta):
	if Global.lives == 0:
		respawn()
		Global.lives = Global.max_lives

	if !is_on_floor():
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

<<<<<<< Updated upstream
	if direction and !is_attacking:
=======
	if direction and not is_attacking and not is_defending:
>>>>>>> Stashed changes
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

<<<<<<< Updated upstream
# Animation Handling
func handle_animations():
	var direction = Input.get_axis("left", "right")
	if is_on_floor() and !dead:
		if Input.is_action_just_pressed("attack_left") and !is_attacking:
			attack_left()
		elif Input.is_action_just_pressed("attack_right") and !is_attacking:
			attack_right()
		elif direction == 0 and !is_attacking:
=======
	# Handle attacking
	if is_on_floor():
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()
		elif is_attacking:
			animated_sprite.play("attack1")  # Play attack animation

		# Handle defending
		elif Input.is_action_just_pressed("defend") and not is_defending:
			defend()
		elif is_defending:
			animated_sprite.play("defend_up")  # Play holding shield animation
		elif direction == 0:
>>>>>>> Stashed changes
			animated_sprite.play("idle")
		elif !is_attacking:
			animated_sprite.play("run")
	elif !is_attacking:
		animated_sprite.play("jump")
	elif dead:
		animated_sprite.play("death")

<<<<<<< Updated upstream
# Separate Attack Functions for Left and Right
func attack_left() -> void:
	if is_attacking:
		return  # Prevent multiple attacks during cooldown
=======
	# Manage attack cooldown
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			
	# Manage defend cooldown
	if is_defending:
		defend_timer -= delta
		if defend_timer <= 0:
			stop_defending()  # Call a function to handle stopping the defense
>>>>>>> Stashed changes

	is_attacking = true
<<<<<<< Updated upstream
	attackType = 1
	attack_applied = false  # Reset damage application flag for new attack
	animated_sprite.play("attack1")  # Replace with left attack animation
	emit_signal("attack")
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	is_attacking = false

func attack_right() -> void:
	if is_attacking:
		return  # Prevent multiple attacks during cooldown

	is_attacking = true
	attackType = 2
	attack_applied = false  # Reset damage application flag for new attack
	animated_sprite.play("attack2")  # Replace with right attack animation
	emit_signal("attack")
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	is_attacking = false

# Check Hitbox for Dealing Damage
func check_hitbox():
	var damage_areas = damage_zone.get_overlapping_areas()
	if damage_zone and is_attacking and !attack_applied:
		for area in damage_areas:
			if area and area.get_parent() is Enemy:
				var enemy = area.get_parent() as Enemy
				if enemy and !enemy.dead:
					handle_attack_damage()
					enemy.take_damage(hitDamage)
					attack_applied = true  # Ensure only one hit per attack animation
					break  # Only apply damage to one enemy per attack

# Function to Handle Damage Amount Based on Attack Type
func handle_attack_damage():
	if attackType == 1:
		hitDamage = 30
	elif attackType == 2:
		hitDamage = 40

# Signal Handlers
func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2"]:
		attack_applied = false  # Reset attack applied flag after animation ends

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
=======
	attack_timer = ATTACK_COOLDOWN
	animated_sprite.play("attack1")

func defend() -> void:
	is_defending = true
	defend_timer = ATTACK_COOLDOWN
	animated_sprite.play("defend_raise")  # Play raise shield animation

func stop_defending() -> void:
	is_defending = false
	animated_sprite.play("defend_down")  # Play lower shield animation
	defend_timer = ATTACK_COOLDOWN  # Reset timer if you want a cooldown

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack1":
		is_attacking = false
	elif anim_name == "defend_down":
		is_defending = false  # Reset defense state when animation ends
>>>>>>> Stashed changes
