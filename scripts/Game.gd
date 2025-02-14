extends Node

var score = 0
var people_delivered = 0
var hud_element

var paused = true

func end_game():
	print("max people reached! game over!")
	hud_element.show_end()
	get_tree().paused = true

func add_people_delivered(amount):
	people_delivered += amount
	hud_element.set_score(people_delivered)

func set_hud(hud):
	hud_element = hud

func start():
	paused = false
