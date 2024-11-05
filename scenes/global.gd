extends Node

# Global Variables
var max_lives = 3
var lives = max_lives

var enemyDamageAmount: int = 10  # Set a default damage amount for enemies
var enemyDamageZone: Area2D  # Reference to the enemy damage zone
var playerDamageZone: Area2D  # Reference to the player's damage zone

# Optionally, you can add functions to manage lives or damage logic

# Function to reset lives to the maximum
func reset_lives() -> void:
	lives = max_lives

# Function to deal damage to the player
func player_takes_damage(damage: int) -> void:
	lives -= damage
	if lives < 0:
		lives = 0  # Ensure lives don't go below zero

# Function to check if player is alive
func is_player_alive() -> bool:
	return lives > 0

# Add any other global management functions you need here
