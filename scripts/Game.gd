extends Node

var score = 0
var people_delivered = 0
var hud

var people_creation_speed = 1000 # interval over which people are created

var paused = true
var start_time

func _ready() -> void:
	start_time = 0

func _process(delta: float) -> void:
	if not paused:
		start_time += delta

	if Input.is_action_just_pressed("pause"):
		paused = not paused

func end_game(people_overrun_by):
	print("max people reached! game over!")
	hud.get_node("End").get_node("HowManyOver").text = str(people_overrun_by)
	hud.show_end()
	get_tree().paused = true

func add_people_delivered(amount):
	people_delivered += amount
	hud.set_score(people_delivered)

func set_hud(hud_element):
	hud = hud_element

func start():
	paused = false

func get_time(): # time game has been played
	return start_time
