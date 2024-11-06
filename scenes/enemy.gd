extends CharacterBody2D
class_name Enemy

# Signals
@warning_ignore("unused_signal")
signal damage
@warning_ignore("unused_signal")
signal update_hearts

# Exported Variables
@export var speed: float = 20.0
@export var left_bound: float = 1265.0
@export var right_bound: float = 1550.0
@export var health_max: int = 80

# Internal Variables
var is_enemy_chase: bool = false
var health: int = 0
var health_min: int = 0
var dead: bool = false
var taking_damage: bool = false
var damage_to_deal: int = 20
var is_dealing_damage: bool = false
var dir: Vector2 = Vector2.RIGHT
const GRAVITY: float = 900.0
var knockback: float = -20.0
var is_roaming: bool = true
var player_in_area: bool = false

# References
@onready var player: CharacterBody2D = $"../Player"  # Ensure the path is correct
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackZone

func _ready() -> void:
	health = health_max
	print("Enemy Health Initialized:", health)

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	handle_anim(delta)
	move_enemy(delta)
	move_and_slide()

@warning_ignore("unused_parameter")
func move_enemy(delta: float) -> void:
	if dead:
		velocity.x = 0
		return

	if not is_enemy_chase:
		# Roaming Logic
		if dir == Vector2.RIGHT and position.x >= right_bound:
			dir = Vector2.LEFT
		elif dir == Vector2.LEFT and position.x <= left_bound:
			dir = Vector2.RIGHT
		velocity.x = dir.x * speed
	elif is_enemy_chase and not taking_damage:
		# Chase Player
		var direction_to_player = (player.position - position).normalized()
		velocity.x = direction_to_player.x * speed
		dir.x = sign(velocity.x)  # Update direction based on velocity
	elif taking_damage:
		# Knockback Logic
		var knockback_dir = (position - player.position).normalized()
		velocity.x = knockback_dir.x * knockback

	is_roaming = true  # Reset roaming status

@warning_ignore("unused_parameter")
func handle_anim(delta: float) -> void:
	if dead:
		if is_roaming:
			is_roaming = false
			animated_sprite.play("death")
			await get_tree().create_timer(1.0).timeout
			handle_death()
	elif taking_damage:
		animated_sprite.play("hit")
		await get_tree().create_timer(0.7).timeout
		taking_damage = false
	elif is_dealing_damage:
		animated_sprite.play("attack")
		pass
	else:
		animated_sprite.play("walk")
		if dir == Vector2.RIGHT:
			animated_sprite.flip_h = false
			attack_area.scale.x = 1  # Set scale to normal for right
		elif dir == Vector2.LEFT:
			animated_sprite.flip_h = true
			attack_area.scale.x = -1  # Flip `attack_area` for left
			
			

func handle_death() -> void:
	queue_free()

# Internal Variables
var is_damaged: bool = false  # Prevents repeated damage within a single attack

@warning_ignore("shadowed_variable")
func take_damage(damage: int) -> void:
	if dead or is_damaged:
		return  # Prevent taking damage if already dead or recently damaged

	health -= damage
	is_damaged = true  # Set is_damaged to prevent further hits during this attack
	taking_damage = true
	print("Enemy took damage:", damage, "Current Health:", health)

	if health <= health_min:
		health = health_min
		dead = true
		print("Enemy is dead.")

	emit_signal("damage")
	if dead:
		emit_signal("update_hearts")

	# Reset is_damaged after a short delay to allow damage again
	await get_tree().create_timer(0.5).timeout
	is_damaged = false
	emit_signal("damage")
	if dead:
		emit_signal("update_hearts")

# Optional: Handle area detection for player proximity
func _on_player_in_range(body: Node) -> void:
	if body is Player:
		is_enemy_chase = true

func _on_player_out_of_range(body: Node) -> void:
	if body is Player:
		is_enemy_chase = false


@warning_ignore("unused_parameter")
func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body is Player and !is_dealing_damage:
		attack_player()


@warning_ignore("unused_parameter")
func _on_attack_zone_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

func attack_player():
	is_dealing_damage = true
	var original_position = attack_area.position
	attack_area.position += Vector2(8, -3)
	animated_sprite.play("attack")
	await get_tree().create_timer(0.4).timeout
	emit_signal("damage")
	await get_tree().create_timer(0.4).timeout
	attack_area.position = original_position
	is_dealing_damage = false
