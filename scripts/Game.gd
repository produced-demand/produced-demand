extends Node

var score = 0
var people_delivered = 0
var hud

var paused = true

func end_game():
	print("max people reached! game over!")
	hud.show_end()
	get_tree().paused = true

func add_people_delivered(amount):
	people_delivered += amount
	hud.set_score(people_delivered)

func set_hud(hud_element):
	hud = hud_element

func start():
	paused = false
