extends CharacterBody2D
class_name Enemy

@export var speed = 20
@export var left_bound = 1265
@export var right_bound = 1550
var is_enemy_chase: bool = false
var health = 80
var health_min = 0
var health_max = 80
var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 20 
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
	if !is_on_floor():
		velocity.y += gravity * delta
	#Global.enemyDamageAmount = damage_to_deal
	#Global.enemyDamageZone = $DamageToDealArea
	handle_anim()
	move(delta)
	move_and_slide()

func move(delta):
	if !dead:
		if !is_enemy_chase:
			if dir == Vector2.RIGHT and position.x >= right_bound:
				dir = Vector2.LEFT
			elif dir == Vector2.LEFT and position.x <= left_bound:
				dir = Vector2.RIGHT
			velocity.x = dir.x * speed
		elif is_enemy_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback
			velocity.x = knockback_dir.x
		is_roaming = true 
	else:
		velocity.x = 0 

func handle_anim():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("hit")
		await get_tree().create_timer(0.7).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("death")
		await get_tree().create_timer(1).timeout
		handle_death()

func handle_death():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	var dir_timer: Timer = $DIrectionTimer
	dir_timer.wait_time = choose([3.0, 4.0, 5.0])
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])

func choose(array):
	array.shuffle()
	return array.front()


func _on_hitbox_area_entered(area: Area2D) -> void:
	var damage = player.hitDamage
	if area == player.playerDamageArea:
		take_damage(damage)
		
func take_damage(damage):
	health = damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
