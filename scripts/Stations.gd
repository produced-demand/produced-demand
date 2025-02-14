extends Node

var max_stations = 10
var stations = []

var route_being_created = false

func add_station(station_node):
	stations.append(station_node)

func find_closest_station(person):
	var target = stations[0]
	var target_distance = get_distance(stations[0].get_global_position(), person.get_global_position())
	for station in stations:
		var distance = get_distance(station.get_global_position(), person.get_global_position())
		if distance < target_distance:
			target = station
			target_distance = distance
	return target

func get_distance(first_position, second_position):
	return abs(sqrt((second_position.y - first_position.y) * (second_position.y - first_position.y) + (second_position.x - first_position.x) * (second_position.x - first_position.x))) 

func can_add_station():
	if len(stations) + 1 <= max_stations and not route_being_created:
		return true
	else:
		return false

func get_index_of_station_at_position(given_position):
	for station_index in range(0, len(stations)):
		var diff_x = abs(stations[station_index].global_position.x - given_position.x)
		var diff_y = abs(stations[station_index].global_position.y - given_position.y)
		if diff_x < 15 and diff_y < 15:
			return station_index
	return -1

func get_station_at_position(given_position):
	for station in stations:
		var diff_x = abs(station.global_position.x - given_position.x)
		var diff_y = abs(station.global_position.y - given_position.y)
		if diff_x < 15 and diff_y < 15:
			return station
	return null

func get_random_station_excluding(excluded_station):
	var random_index = randi_range(0, len(stations) - 1)
	if stations[random_index] == excluded_station:
		return get_random_station_excluding(excluded_station)
	else:
		return stations[random_index]

func set_route_being_created(value):
	route_being_created = value
