extends Node2D

var route
var parent
var reverse: bool = false
var route_closed: bool
var progress_ratio

var last_point
var current_station = null
var last_station

var has_reached_end = false

var time_arrived_at_station = -1
var wait_time

@export var top_speed = 180
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
	parent.progress = 0
	progress_ratio = parent.progress_ratio
	var closest_point = route.get_closest_point(global_position)
	last_point = closest_point
	current_station = Stations.get_station_at_position(closest_point.position)
	entered_station(current_station)
	route.register_bus(self)

func _process(delta: float) -> void:
	if Game.paused:
		return

	if is_at_station():
		collect_people()
		if Time.get_ticks_msec() - time_arrived_at_station > wait_time: # TO-DO: this will not care about paused
			exit_station()

	var new_speed = update_bus_speed(delta)
	var change = new_speed * delta
	update_bus_position(change)

func update_bus_speed(delta):
	speed += acceleration * delta
	if speed > top_speed:
		acceleration = 0
		speed = top_speed
	return speed

func update_bus_position(change):
	if not route_closed and reverse:
		change *= -1

	var new_progress = parent.get_progress() + change
	if new_progress > parent.get_parent().curve.get_baked_length():
		new_progress = parent.get_parent().curve.get_baked_length()
		new_progress = handle_end_behavior(new_progress)
	if new_progress < 0:
		new_progress = 0
		new_progress = handle_end_behavior(new_progress)

	update_bus_direction()
	parent.set_progress(new_progress)
	progress_ratio = parent.get_progress_ratio()

func handle_end_behavior(new_progress):
	if has_reached_end and not route_closed:
		reverse = not reverse
		has_reached_end = false
	elif has_reached_end and route_closed:
		parent.set_progress_ratio(1)
		new_progress = 0
		has_reached_end = false
	return new_progress

# ======================================================

func entered_station_range(station):
	if route.has_station(station) and current_station == null and is_approaching_station(station):
		print("entered station range")
		current_station = station
		var distance_to_station = get_distance_to_station(station)
		acceleration = (0 - pow(speed, 2)) / (2 * distance_to_station)

func exited_station_range(station):
	if current_station == station || last_station == station:
		print("left station, set to zero")
		acceleration = 0
		speed = top_speed

func entered_station(station):
	if station == current_station and not Game.paused:
		print("arrived at station: " + str(station))
		acceleration = 0
		speed = 0
		time_arrived_at_station = Time.get_ticks_msec()

		# people are removed, their data should be saved
		var people_delivered = current_station.deliver_people(occupants)
		for person in people_delivered:
			var person_index = occupants.find(person, 0)
			occupants.remove_at(person_index)
			PeopleGenerator.regenerate_person(current_station.global_position, person)

		wait_time = current_station.get_wait_time(get_open_seats())

func exit_station():
	acceleration = ((pow(top_speed, 2)) / (2 * 80)) # kinematics equation: vf^2 = vi^2 + 2ax; 80 because it would be a pain to calculate it
	last_station = current_station
	current_station = null
	time_arrived_at_station = -1

# ======================================================

func is_approaching_station(station):
	var next_point_with_station = route.get_next_point_with_station(last_point, reverse)
	if not Stations.stations[Stations.get_index_of_station_at_position(next_point_with_station.position)] == station:
		return false

	var radius = station.get_node("Nearby").get_node("Collider").shape.radius

	var current_point = route.get_next_point(last_point, reverse)
	while current_point != next_point_with_station:
		if not in_given_range(radius, station.global_position, current_point.position):
			return false
		current_point = route.get_next_point(current_point, reverse)

	# if it reaches here, all next points until station are in range
	return true


func get_distance_to_station(_station):
	var next_point = route.get_next_point(last_point, reverse)
	var distance_to = distance(global_position, next_point.position)
	if next_point.atStation:
		return distance_to
	var current_point = next_point
	next_point = route.get_next_point(next_point, reverse)
	
	while (not next_point.atStation):
		distance_to += distance(current_point.position, next_point.position)
		current_point = next_point
		next_point = route.get_next_point(next_point, reverse)
	distance_to += distance(current_point.position, next_point.position)

	return distance_to

func in_given_range(radius, target, point):
	return distance(target, point) <= radius

func set_last_point(point):
	if point == route.get_next_point(last_point, reverse) and not Game.paused:
		last_point = point
		print("set last point")
		if route.is_end_point(point):
			print("starting end behaviour")
			has_reached_end = true

func has_been_moved():
	# NEED TO DO SOMETHING ABOUT LAST-POINT HERE
		# may be able to calculate by using direction of bus velocity
	## may actually be useful
	#var station_bus_is_in_range_of = Stations.get_station_at(global_position)
	#if station_bus_is_in_range_of == current_station and current_station != null:
		#entered_station(current_station)

	##print(station_bus_is_in_range_of)
	#if station_bus_is_in_range_of == null:
		#return
	#else:
		#entered_station_range(station_bus_is_in_range_of)
	#set_to_progress_ratio()
	#print("Has been moved " + str(current_station))
	pass

# ======================================================

func collect_people():
	var new_occupants = current_station.get_people(get_open_seats(), route)
	for occupant in new_occupants:
		occupants.append(occupant)
	update_occupants_label()

func update_bus_direction():
	if reverse:
		get_node("Sprite").flip_h = 1
		get_node("Label").position.x = -1
	else:
		get_node("Sprite").flip_h = 0
		get_node("Label").position.x = -28

func set_to_progress_ratio():
	parent.progress_ratio = progress_ratio

func update_occupants_label():
	$Label.text = str(len(occupants))

func set_route_closed(value: bool):
	route_closed = value

func get_open_seats():
	return max_occupancy - len(occupants)

func on_route(given_route):
	return given_route == route

func distance(pos1, pos2):
	return sqrt((pos2.x - pos1.x) ** 2 + (pos2.y - pos1.y) ** 2)
