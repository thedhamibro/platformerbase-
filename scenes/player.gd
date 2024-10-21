extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum State {
	IDLE,
	RUN,
	JUMP,
	ATTACK
}

var current_state = State.IDLE
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	handle_input()
	move_and_slide()

func handle_input() -> void:
	var direction = Input.get_axis("left", "right")

	# Jumping logic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		set_state(State.RUN)
	else:
		velocity.x = 0  # Reset horizontal velocity when no input
		if is_on_floor():
			set_state(State.IDLE)

	# Attack logic
	if is_on_floor() and Input.is_action_just_pressed("attack") and current_state != State.ATTACK:
		attack()

	# Update state if in the air
	if not is_on_floor() and current_state != State.JUMP:
		set_state(State.JUMP)

func attack() -> void:
	set_state(State.ATTACK)
	animated_sprite.play("attack1")

func set_state(new_state: State) -> void:
	if new_state != current_state:
		current_state = new_state
		match current_state:
			State.IDLE:
				animated_sprite.play("idle")
			State.RUN:
				animated_sprite.play("run")
			State.JUMP:
				animated_sprite.play("jump")
			State.ATTACK:
				animated_sprite.play("attack1")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack1":
		current_state = State.IDLE if is_on_floor() else State.JUMP
