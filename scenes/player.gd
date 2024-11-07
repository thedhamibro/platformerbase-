extends CharacterBody2D
class_name Player

# Signals
signal damage
signal update_hearts

# Movement Variables
@export var SPEED: float = 130.0
@export var JUMP_VELOCITY: float = -300.0
const ATTACK_COOLDOWN: float = 0.5
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_checkpoint_position: Vector2 = Vector2()
@onready var damage_zone: Area2D = $"Damage Zone"  # Ensure the path is correct

# Attack Variables
var is_attacking: bool = false
var attack_timer: float = ATTACK_COOLDOWN
var hitDamage: int = 0
var attackType: int = 0

# Node References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HItbox  # Ensure the path is correct

# Physics Process
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_animations(delta)
	move_and_slide()
	check_hitbox()
	Global.playerDamageZone = damage_zone  # Ensure Global is correctly set up

# Movement Handling (without smooth movement)
func handle_movement(delta: float) -> void:
	if Global.lives == 0:
		get_tree().reload_current_scene()
		Global.lives = Global.max_lives

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction > 0 and not is_attacking:
		velocity.x = SPEED  # Move directly to the right
		animated_sprite.flip_h = false
		damage_zone.scale.x = 1  # Set scale to normal for right
	elif direction < 0 and not is_attacking:
		velocity.x = -SPEED  # Move directly to the left
		animated_sprite.flip_h = true
		damage_zone.scale.x = -1  # Flip damage zone for left
	else:
		velocity.x = 0  # Stop immediately

# Animation Handling
func handle_animations(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	if is_on_floor():
		if Input.is_action_just_pressed("attack_left") and not is_attacking:
			attack_left()
		elif Input.is_action_just_pressed("attack_right") and not is_attacking:
			attack_right()
		elif direction == 0 and not is_attacking:
			animated_sprite.play("idle")
		elif not is_attacking:
			animated_sprite.play("run")
	elif not is_attacking:
		animated_sprite.play("jump")

# Attack Handling
func attack_left() -> void:
	if is_attacking: return  # Prevent attacking if already attacking
	is_attacking = true
	attackType = 1
	hitDamage = 30
	animated_sprite.play("attack1")  # Replace with your left attack animation

	# Start cooldown to prevent multiple damage checks
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func attack_right() -> void:
	if is_attacking: return  # Prevent attacking if already attacking
	is_attacking = true
	attackType = 2
	hitDamage = 40
	animated_sprite.play("attack2")  # Replace with your right attack animation

	# Start cooldown to prevent multiple damage checks
	await get_tree().create_timer(0.6).timeout
	is_attacking = false

# Check Hitbox
func check_hitbox() -> void:
	if not is_attacking: return  # Only check hitbox when attacking

	# Perform damage check only once per attack
	var hitbox_areas = damage_zone.get_overlapping_areas()
	for area in hitbox_areas:
		if area.get_parent() is Enemy:
			var enemy = area.get_parent() as Enemy
			if enemy and enemy.is_inside_tree() and not enemy.is_damaged:
				enemy.take_damage(hitDamage)

# Signal Handlers
func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2"]:
		is_attacking = false

func _on_damage() -> void:
	Global.lives -= 1
	respawn()

func _on_player_reached_checkpoint(position: Vector2) -> void:
	print("Checkpoint reached at:", position)
	last_checkpoint_position = position

# Respawn Function
func respawn() -> void:
	position = last_checkpoint_position
	emit_signal("update_hearts")

# Damage Zone Signal Handler
func _on_damage_zone_body_entered(body: Node) -> void:
	#handle_attack_damage(body.name)  # Optional based on your logic
	pass
