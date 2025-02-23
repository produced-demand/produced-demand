extends Area2D

var people: int = 0
var happy_people: int = 0 # this is temporary, until global score is kept
var dream_stations: Array

var routes: Array

func _ready() -> void:
	Stations.add_station(self)
	
	connect("area_entered", _something_in_station)
	$Nearby.connect("area_entered", _on_range_entered)
	$Nearby.connect("area_exited", _on_range_exited)

func add_person(person):
	people += 1
	if people > Stations.max_people_at_station:
		Game.end_game(people)
	dream_stations.append(person.get_dream_station())
	person.joined_station() # removes person
	update_occupants_label()
	
func update_occupants_label():
	get_node("Label").text = str(people)

func add_route(route):
	#if not route in routes:
	routes.append(route)

func get_wait_time(spots_available):
	var potential_passengers
	if spots_available < people:
		potential_passengers = spots_available
	else:
		potential_passengers = people
	return 400 + (potential_passengers * 300)


# needed code in these two functions can probably be extracted
func get_people(amount_of_people: int, route):
	var people_to_send: Array

	for dream in dream_stations:
		if amount_of_people == 0:
			break
		if route_leads_to_dream(dream, route):
			var dream_index = dream_stations.find(dream)
			people_to_send.append(dream)
			dream_stations.remove_at(dream_index)
			amount_of_people -= 1
		#else:
			#print("dream: " + str(dream) + " - " + str(route.stations))
			#print(dream in route.stations)
			#print("person rejected unfairly")

	people -= len(people_to_send)
	update_occupants_label()
	return people_to_send

func deliver_people(peoples_dreams: Array):
	# this should also deliver people if the station is on the way to their final one!
	var people_to_deliver: Array
	for dream in peoples_dreams:
		if (dream == self) or station_leads_to_dream(dream, self, [], []):
			people_to_deliver.append(dream)
			happy_people += 1
			Game.add_people_delivered(1)
	return people_to_deliver

func station_leads_to_dream(dream, current_station, checked_routes: Array, checked_stations: Array):
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

func route_leads_to_dream(dream, route):
	var excluded_routes = routes.duplicate()
	excluded_routes.remove_at(excluded_routes.find(route, 0))
	return (dream in route.stations) or station_leads_to_dream(dream, self, excluded_routes, [])


func _on_range_entered(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.approaching_station(self)

func _on_range_exited(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.left_station(self)

func _something_in_station(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.at_station(self)
