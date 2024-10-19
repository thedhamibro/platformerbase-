extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -250
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		animated_sprite_2d.play("jump")
		velocity.y = JUMP_VELOCITY


	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("walk")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
