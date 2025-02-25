extends Node2D

var route
var parent
var reverse: bool = false
var route_closed: bool

var current_station
var visited = false
var is_at_station = false
var last_point
var last_station

@export var top_speed = 200
var speed
var acceleration = 0
var max_occupancy = 8
var occupants: Array

var time_arrived_at_station = -1
var wait_time

func _ready() -> void:
	speed = top_speed
	parent = get_parent()
	route = parent.get_parent()
	parent.progress_ratio = 0 # 0-1
	last_point = route.get_closest_point(self)

func _process(delta: float) -> void:
	if Game.paused:
		return

	if current_station:
		if not visited and is_at_station:
			# add new passengers
			var new_occupants = current_station.get_people(get_open_seats(), route)
			for occupant in new_occupants:
				occupants.append(occupant)
			update_occupants_label()
			
			if Time.get_ticks_msec() - time_arrived_at_station > wait_time:
				# leave
				acceleration = ((pow(top_speed, 2)) / (2 * 80))
				visited = true
				is_at_station = false
				last_point = route.get_point_at_position(current_station.global_position)
				last_station = current_station
				current_station = null
				time_arrived_at_station = -1


	# slow down / speed up
	speed += acceleration * delta
	# the reason this will happen when leaving stations is because there is extra time
	# where the bus is accelerated when it goes behind the station
	if speed > top_speed:
		acceleration = 0
		speed = top_speed

	var change = speed * delta

	if not route_closed:
		if parent.get_progress_ratio() >= .98:
			reverse = true
		elif parent.get_progress_ratio() <= .02:
			reverse = false
		if reverse:
			change *= -1

	var new_progress = parent.get_progress() + change
	parent.set_progress(new_progress)

# entering range of station
func approaching_station(station):
	# should only slow down if it plans on going to the station
	if current_station == null and route.has_station(station) and is_approaching_station(station):
		current_station = station
		
		var distance_to_station = get_distance_to_station(station)
		# should use actual path distance instead of assumption of a straight line
		acceleration = (0 - pow(speed, 2)) / (2 * distance_to_station) # global_position.distance_to(station.global_position)

# leaving range of station
func left_station(station):
	if route.has_station(station) and last_station == station:
		visited = false
		acceleration = 0
		speed = top_speed

# arriving at station
func at_station(station):
	if station == current_station:
		time_arrived_at_station = Time.get_ticks_msec()

		var people_delivered = current_station.deliver_people(occupants)
		for person in people_delivered:
			var person_index = occupants.find(person, 0)
			occupants.remove_at(person_index)

		wait_time = current_station.get_wait_time(get_open_seats())
		is_at_station = true
		acceleration = 0
		speed = 0

func is_approaching_station(station):
	var next_point = route.get_next_point_with_station(last_point, reverse)
	# if next point is station
	if (next_point.position == station.global_position):
		return true
	# if reaches station before leaving area
	var radius = station.get_node("Nearby").get_node("Collider").shape.radius
	while (in_given_range(radius, station.global_position, next_point)):
		if Stations.get_index_of_station_at_position(next_point.position) != -1:
			return true
		next_point = route.get_next_point_with_station(next_point, reverse)
	return false

func get_distance_to_station(station):
	var next_point = route.get_next_point(last_point, reverse)
	var distance = distance(global_position, next_point.position) # global_position.distance_to(next_point.position)
	var current_point = next_point
	next_point = route.get_next_point(next_point, reverse)
	
	while (not next_point.atStation):
		distance += distance(current_point.position, next_point.position) # current_point.position.get_distance_to(next_point.position)
		current_point = next_point
		next_point = route.get_next_point(next_point, reverse)

	return distance

func distance(pos1, pos2):
	return sqrt((pos2.x - pos1.x) ** 2 + (pos2.y - pos1.y) ** 2)

func in_given_range(radius, target, point):
	if point.position.x < target.x + radius and point.position.x > target.x - radius:
		if point.position.y < target.y + radius and point.position.y > target.y - radius:
			return true
	return false

func update_occupants_label():
	$Label.text = str(len(occupants))

func set_route_closed(value: bool):
	route_closed = value

func get_open_seats():
	return max_occupancy - len(occupants)
