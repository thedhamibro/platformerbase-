extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ATTACK_COOLDOWN = 2  # Time in seconds before another attack can occur

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

var is_attacking = false
var attack_timer = ATTACK_COOLDOWN
var attack_combo = 0  # Tracks the current attack in the combo
var is_defending = false  # Declare the defending variable

func _physics_process(delta):
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jumping logic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle horizontal movement
	var direction = Input.get_axis("left", "right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if direction and not is_attacking and not is_defending:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle attacking
	if is_on_floor():
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()
		elif is_attacking:
			# Check if the attack combo should continue based on the attack timer
			if attack_timer <= 0:
				attack_combo = (attack_combo + 1) % 3  # Cycle through 0, 1, 2
				attack()  # Trigger the next attack in the combo
		elif Input.is_action_just_pressed("defend") and not is_defending:
			defend()
		elif is_defending:
			animated_sprite.play("defend")  # Play the defend animation
		elif direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Manage attack cooldown
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			attack_combo = 0  # Reset the combo after cooldown

	# Check for defending state
	if is_defending and not Input.is_action_pressed("defend"):
		stop_defending()  # Stop defending if the button is released

	move_and_slide()

func attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN

	# Play the appropriate attack animation based on the combo state
	match attack_combo:
		0:
			animated_sprite.play("attack1")
		1:
			animated_sprite.play("attack2")
		2:
			animated_sprite.play("attack3")

func defend() -> void:
	is_defending = true
	animated_sprite.play("defend")  # Play defend animation

func stop_defending() -> void:
	is_defending = false
	if is_on_floor():
		animated_sprite.play("idle")  # Return to idle when defense ends

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack1" or anim_name == "attack2" or anim_name == "attack3":
		is_attacking = false
		attack_timer = 0.5  # Reset the timer for the next combo opportunity
