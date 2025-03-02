extends Node2D

var route
var parent
var reverse: bool = false
var route_closed: bool

var last_point
var last_station

var current_station

var time_arrived_at_station = -1
var wait_time

@export var top_speed = 200
var speed
var acceleration = 0
var max_occupancy = 8
var occupants: Array


func is_at_station():
	return time_arrived_at_station != -1

func _ready() -> void:
	speed = top_speed
	parent = get_parent()
	route = parent.get_parent()
	parent.progress_ratio = 0 # 0-1
	last_point = route.get_closest_point(self)

func _process(delta: float) -> void:
	if Game.paused:
		return

	if is_at_station():
		collect_people()
		if Time.get_ticks_msec() - time_arrived_at_station > wait_time:
			exit_station()

	var speed = update_bus_speed(delta)
	var change = speed * delta
	update_bus_position(change)


func entered_station_range(station):
	print("hai: " + str(is_approaching_station(station)))
	return
	if current_station == null and route.has_station(station) and is_approaching_station(station):
		print("set current station")
		print(station)
		current_station = station

		var distance_to_station = get_distance_to_station(station) # value may currently be off
		acceleration = (0 - pow(speed, 2)) / (2 * distance_to_station)

# leaving range of station
func exited_station_range(station):
	return
	if route.has_station(station): # and last_station == station:
		acceleration = 0
		speed = top_speed

# arriving at station
func entered_station(station):
	return
	print("now at station")
	print(current_station)
	if station == current_station: #cd  and route.get_next_point(last_point, reverse).atStations:
		time_arrived_at_station = Time.get_ticks_msec()

		var people_delivered = current_station.deliver_people(occupants)
		for person in people_delivered:
			var person_index = occupants.find(person, 0)
			occupants.remove_at(person_index)

		wait_time = current_station.get_wait_time(get_open_seats())
		acceleration = 0
		speed = 0

func exit_station():
	return
	# leave
	acceleration = ((pow(top_speed, 2)) / (2 * 80))
	last_point = route.get_point_at_position(current_station.global_position)
	last_station = current_station
	current_station = null
	time_arrived_at_station = -1



func is_approaching_station(station):
	# checking that next station 
	var next_point_with_station = route.get_next_point_with_station(last_point, reverse)
	if not Stations.stations[Stations.get_index_of_station_at_position(next_point_with_station.position)] == station:
		return false
		
	var first_point_in_range
	var next_point = last_point
	var radius = station.get_node("Nearby").get_node("Collider").shape.radius
	print("--")
	while not in_given_range(radius, station.global_position, next_point):
		next_point = route.get_next_point(next_point, reverse)
		print(next_point)
	first_point_in_range = next_point
	last_point = first_point_in_range
	print("---")
	var none_outside_range = all_between_points_in_range(first_point_in_range, next_point_with_station, radius)
	print("howdy " + str(none_outside_range))
	return none_outside_range

func all_between_points_in_range(first_point, last_point, radius):
	var current_point = first_point
	#print(str(current_point) + " ; " + str(last_point))
	
	print("haaiii")
	while current_point != last_point:
		if not in_given_range(radius, last_point.position, current_point):
			print("badddddddddddddddddddddddddd")
			return false
		current_point = route.get_next_point(current_point, reverse)
	print("they the saaaame")
	return true

func get_distance_to_station(station):
	var next_point = route.get_next_point(last_point, reverse)
	var distance_to = distance(global_position, next_point.position)
	var current_point = next_point
	next_point = route.get_next_point(next_point, reverse)
	
	while (not next_point.atStation):
		distance_to += distance(current_point.position, next_point.position)
		current_point = next_point
		next_point = route.get_next_point(next_point, reverse)
	distance_to += distance(current_point.position, next_point.position)

	return distance_to

func distance(pos1, pos2):
	return sqrt((pos2.x - pos1.x) ** 2 + (pos2.y - pos1.y) ** 2)

func in_given_range(radius, target, point):
	var origin_to_point_distance = distance(target, point.position)
	if origin_to_point_distance <= radius:
		return true
	return false


func update_bus_speed(delta):
	speed += acceleration * delta
	if speed > top_speed:
		acceleration = 0
		speed = top_speed
	return speed

func update_bus_position(change):
	if not route_closed:
		if parent.get_progress_ratio() >= .98:
			reverse = true
		elif parent.get_progress_ratio() <= .02:
			reverse = false
		if reverse:
			change *= -1

	var new_progress = parent.get_progress() + change
	parent.set_progress(new_progress)

func collect_people():
	var new_occupants = current_station.get_people(get_open_seats(), route)
	for occupant in new_occupants:
		occupants.append(occupant)
	update_occupants_label()

func update_occupants_label():
	$Label.text = str(len(occupants))

func set_route_closed(value: bool):
	route_closed = value

func get_open_seats():
	return max_occupancy - len(occupants)

func on_route(given_route):
	return given_route == route

func set_last_point(point):
	print("last-point" + str(point))
	last_point = point
