extends Node

var score = 0
var people_delivered = 0
var hud
var route_creator
var camera

var people_creation_speed = 2000 # interval over which people are created

var paused = true
var start_time

var resource_limits = {
	"max_stations": 10,
	"max_routes": 8
}

var max_people_at_station = 120

func _ready() -> void:
	start_time = 0

func _process(delta: float) -> void:
	if not paused:
		start_time += delta

	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func reset():
	start_time = 0
	score = 0
	people_delivered = 0
	Stations.reset()

func end_game(people_overrun_by):
	hud.get_node("End").get_node("HowManyOver").text = str(people_overrun_by)
	hud.show_end()
	paused = true

func win():
	hud.show_win()

func add_people_delivered(amount):
	people_delivered += amount
	hud.set_score(people_delivered)
	if people_delivered > 3000:
		Game.win()

func start():
	paused = false

func toggle_pause():
	paused = not paused
	hud.get_node("Controls").get_node("PlayPause").get_node("Icon").texture = load("res://assets/icons/play.svg") if paused else load("res://assets/icons/pause.svg")

func get_time(): # time game has been played
	return start_time

func get_max_stations():
	return resource_limits.max_stations
func get_max_routes():
	return resource_limits.max_routes

func set_hud(hud_element):
	hud = hud_element
func set_route_creator(script):
	route_creator = script
func register_camera(script):
	camera = script

func get_route_count():
	return route_creator.get_route_count()
