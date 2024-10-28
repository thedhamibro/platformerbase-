extends CharacterBody2D

@onready var player: CharacterBody2D = $"../player"
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $AnimatedSprite2D/ai
@onready var enemy_rc: RayCast2D = $AnimatedSprite2D/enemy
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2

enum States {WANDER, CHASE, ATTACK}
var current_state = States.WANDER
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0

func _ready() -> void:
	left_bounds = self.position + Vector2(-125, 0)
	right_bounds = self.position + Vector2(125, 0)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	look_for_player()
	if current_state == States.CHASE:
		attack_timer -= delta
		if attack_timer <= 0:
			attack_player()

func look_for_player() -> void:
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_movement(delta: float) -> void:
	if current_state in [States.WANDER, States.CHASE]:
		sprite.play("walk")
		velocity = velocity.move_toward(direction * (SPEED if current_state == States.WANDER else CHASE_SPEED), ACCELERATION * delta)
	elif current_state == States.ATTACK:
		velocity = Vector2.ZERO
		if sprite.animation != "attack":
			sprite.play("attack")
	move_and_slide()

func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()
		current_state = States.WANDER

func attack_player() -> void:
	if enemy_rc.is_colliding():
		var enemy_collider = enemy_rc.get_collider()
		if enemy_collider == player:
			if current_state != States.ATTACK:
				current_state = States.ATTACK
				attack_timer = attack_cooldown
				sprite.play("attack")
		else:
			current_state = States.CHASE

func change_direction() -> void:
	var collision_offset = Vector2(17, 2)
	var flip_offset = Vector2(-15, 0)
	if current_state == States.WANDER:
		if sprite.flip_h:
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				sprite.flip_h = false
				self.position += flip_offset
				ray_cast.target_position = Vector2(-125, 0)
				collision_shape.position += collision_offset
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				sprite.flip_h = true
				self.position -= flip_offset
				ray_cast.target_position = Vector2(125, 0)
				collision_shape.position -= collision_offset
	else:
		direction = (player.position - self.position).normalized()
		if direction.x > 0:
			sprite.flip_h = false
			self.position += flip_offset
			ray_cast.target_position = Vector2(125, 0)
			collision_shape.position += collision_offset
		else:
			sprite.flip_h = true
			self.position -= flip_offset
			ray_cast.target_position = Vector2(-125, 0)
			collision_shape.position -= collision_offset
