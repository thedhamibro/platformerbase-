extends Node

var score = 0
var coins = 0
@onready var coinLabel: Label = $Coin
@onready var scoreLabel: Label = $Score

func _process(delta: float) -> void:
	$GUI2/Coin.text = str(coins)
	
