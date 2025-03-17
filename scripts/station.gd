extends Area2D

var people: Array
var happy_people: int = 0 # this is temporary, until global score is kept

var routes: Array

var random_strength = 15
var shakeFade = 5
var shake_strength = 0

func _ready() -> void:
	Stations.add_station(self)
	
	connect("area_entered", _something_in_station)
	$Nearby.connect("area_entered", _on_range_entered)
	$Nearby.connect("area_exited", _on_range_exited)

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		get_node("Sprite2D").position = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func add_person(person):
	people.append({
		"last_station": person.get_dream_station(),
		"position_goal": person.position_goal,
		"distance_walked": person.distance_walked,
		"speed": person.speed
	})

	person.joined_station() # removes person
	update_occupants_label()

	if len(people) > Game.max_people_at_station:
		Game.end_game(len(people))

func update_occupants_label():
	get_node("Label").text = str(len(people))

func add_route(route):
	# if not route in routes: # not sure why this was commented, try it out later
	routes.append(route)

func get_wait_time(spots_available):
	var potential_passengers
	if spots_available < len(people):
		potential_passengers = spots_available
	else:
		potential_passengers = len(people)
	return 400 + (potential_passengers * 300) # 400 is the base time, 300 is additional per passenger


# needed code in these two functions can probably be extracted
func get_people(amount_of_people: int, route):
	var people_to_send: Array

	for person in people:
		if amount_of_people == 0:
			break
		if route_leads_to_dream(person.last_station, route):
			var person_index = people.find(person)
			people_to_send.append(person)
			people.remove_at(person_index)
			amount_of_people -= 1
		# try this a final time then remove
		#else:
			#print("dream: " + str(dream) + " - " + str(route.stations))
			#print(dream in route.stations)
			#print("person rejected unjustly")

	update_occupants_label()
	return people_to_send

func deliver_people(new_people: Array):
	var people_to_deliver: Array
	for person in new_people:
		if (person.last_station == self) or station_leads_to_dream(person.last_station, self, [], []):
			people_to_deliver.append(person)
			happy_people += 1
			Game.add_people_delivered(1)
	return people_to_deliver

func station_leads_to_dream(dream, current_station, checked_routes: Array, checked_stations: Array): # dream here is last_station
	# routes of this station
	for route in current_station.routes:
		if not route in checked_routes:
			checked_routes.append(route)
			for station in route.stations:
				if not station in checked_stations:
					if station == dream:
						return true
					else:
						checked_stations.append(station)
						var result = station_leads_to_dream(dream, station, checked_routes, checked_stations)
						if result:
							return true
	return false

func route_leads_to_dream(dream, route): # dream here is last_station
	var excluded_routes = routes.duplicate()
	excluded_routes.remove_at(excluded_routes.find(route, 0))
	return (dream in route.stations) or station_leads_to_dream(dream, self, excluded_routes, [])

func shake():
	shake_strength = random_strength

func _on_range_entered(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.entered_station_range(self)

func _on_range_exited(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.exited_station_range(self)

func _something_in_station(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.entered_station(self)
