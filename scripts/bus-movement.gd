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
var occupancy
var occupants

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
				acceleration = (0 - speed ^ 2) / (2 * global_position.distance_to(station.global_position))
				
				if station != current_station:
					current_station = station
	else:
		var lastspeed = speed
		speed += acceleration * delta * 100

		if not visited:
			if global_position.distance_to(current_station.global_position) <= 9:
				speed = 0
				# after has waited for all passengers to board
				acceleration = ((speed ^ 2 - 0) / (2 * global_position.distance_to(current_station.global_position)))
				visited = true

		elif visited:
			if speed == 0:
				speed = 1
			speed += acceleration * delta * 100
			
			if global_position.distance_to(current_station.global_position) > 80:
				current_station = null
				visited = false
				speed = top_speed
				acceleration = 0
				
	var new_progress = parent.get_progress() + change
	parent.set_progress(new_progress)



func set_route_closed(value: bool):
	route_closed = value
