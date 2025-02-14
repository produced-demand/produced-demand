extends Node2D

var route
var parent
var reverse: bool = false
var route_closed: bool

var current_station
var visited = false
var is_at_station = false

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
	parent.progress_ratio = .5

func _process(delta: float) -> void:
	if Game.paused:
		return

	if current_station:
		if not visited and is_at_station:
			if Time.get_ticks_msec() - time_arrived_at_station > wait_time:
				# add new passengers
				var new_occupants = current_station.get_people(get_open_seats(), route)
				for occupant in new_occupants:
					occupants.append(occupant)
				update_occupants_label()
				# leave
				acceleration = ((pow(top_speed, 2)) / (2 * 80))
				visited = true
				is_at_station = false

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

# entering rango of station
func approaching_station(station):
	if route.has_station(station):
		current_station = station
		acceleration = (0 - pow(speed, 2)) / (2 * global_position. distance_to(station.global_position))

# leaving range of station
func left_station(station):
	if route.has_station(station) and station == current_station:
		current_station = null
		visited = false
		time_arrived_at_station = -1
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


func update_occupants_label():
	$Label.text = str(len(occupants))

func set_route_closed(value: bool):
	route_closed = value

func get_open_seats():
	return max_occupancy - len(occupants)
