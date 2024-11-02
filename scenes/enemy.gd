extends CharacterBody2D
class_name Enemy

@export var speed = 10
var is_frog_chase: bool

var health = 80
var dead:bool = false
var taking_damage: bool = false
var damage_to_deal = 20	
var is_dealing_damage: bool = false
var dir: Vector2
const gravity = 900
var knockback
var is_roaming: bool = true
