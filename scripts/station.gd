extends Area2D

var people: int
var dream_stations: Array

var routes: Array

func _ready() -> void:
	Stations.add_station(self)

func add_person(person):
	people += 1
	if people > 600:
		# make wordless game over screen later
		print("max people reached! game over!")
		get_tree().paused = true
	dream_stations.append(person.get_dream_station())
	person.joined_station() # removes person
	update_occupants_label()
	
func update_occupants_label():
	get_node("Label").text = str(people)

func add_route(route):
	routes.append(route)
	
func take_people(people_amount, stations):
	print(people_amount)
	print(stations)
