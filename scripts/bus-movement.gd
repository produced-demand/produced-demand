extends Node2D

var route
var parent
var reverse: bool = false
var route_closed: bool

var current_station
var visited = false

@export var top_speed = 100
var speed = top_speed
var acceleration
var max_occupancy = 8
var occupants: Array

var time_arrived_at_station = -1
var wait_time

func _ready() -> void:
	parent = get_parent()
	route = parent.get_parent()
	parent.progress_ratio = int(randf())

func _process(delta: float) -> void:
	var change = speed * delta

	if not route_closed:
		if parent.get_progress_ratio() >= .99:
			reverse = true
		elif parent.get_progress_ratio() <= .01:
			reverse = false
		if reverse:
			change *= -1
		

	if !current_station:
		for station in route.stations:
			if global_position.distance_to(station.global_position) < 80:
				current_station = station
				acceleration = (pow(speed, 2)) / (2 * global_position.distance_to(station.global_position))
				
				if station != current_station:
					current_station = station
	else:
		speed += acceleration * delta
		
		if not visited:

			if global_position.distance_to(current_station.global_position) <= 9:
				speed = 0
				if time_arrived_at_station == -1:
					time_arrived_at_station = Time.get_ticks_msec()
					wait_time = current_station.get_wait_time(max_occupancy - len(occupants))
					var new_occupants = current_station.get_people(max_occupancy - len(occupants), route)
					for occupant in new_occupants:
						occupants.append(occupant)
					update_occupants_label()
				elif Time.get_ticks_msec() - time_arrived_at_station > wait_time:
					acceleration = ((pow(top_speed, 2)) / (2 * 80))
					visited = true

		elif visited:			
			if global_position.distance_to(current_station.global_position) > 80:
				current_station = null
				visited = false
				time_arrived_at_station = -1
				speed = top_speed
				acceleration = 0
				
	var new_progress = parent.get_progress() + change
	parent.set_progress(new_progress)

func update_occupants_label():
	$Label.text = str(len(occupants))

func set_route_closed(value: bool):
	route_closed = value
