extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ATTACK_COOLDOWN = 0.5  # Time in seconds before another attack can occur

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

var is_attacking = false
var attack_timer = 0.0

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

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle attacking
	if is_on_floor():
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()
		elif is_attacking:
			animated_sprite.play("attack1")  # Play attack animation
		elif direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Handle attack cooldown
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false  # Reset attack state after cooldown

	move_and_slide()

func attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN  # Set cooldown
	# Play attack animation (if not already handled in the main loop)
	animated_sprite.play("attack1")
	# Here you could call a function to detect hits (e.g. check for colliDAsions with enemies)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack1":
		# Reset the attack state when the animation is finished
		is_attacking = false
