extends Node

var score = 0

func end_game():
	print("max people reached! game over!")
	# need to make a wordless game over screen
	get_tree().paused = true
