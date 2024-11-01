extends Node

var score = 0
var coins = 0
var max_lives = 3
var lives = max_lives
@onready var coinLabel: Label = $Coin
@onready var scoreLabel: Label = $Score

func _process(delta: float) -> void:
	$GUI2/Coin/Coin.text = str(coins)
	
