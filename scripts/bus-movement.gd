extends Node2D

var route
var parent
var reverse: bool = false
var route_closed: bool

var current_station
var visited = false
var is_at_station = false

@export var top_speed = 50
var speed
var acceleration
var max_occupancy = 8
var occupants: Array

var time_arrived_at_station = -1
var wait_time

func _ready() -> void:
	speed = top_speed
	parent = get_parent()
	route = parent.get_parent()
	parent.progress_ratio = randf()

func _process(delta: float) -> void:
	var change = speed * delta

	if not route_closed:
		if parent.get_progress_ratio() >= .98:
			reverse = true
		elif parent.get_progress_ratio() <= .02:
			reverse = false
		if reverse:
			change *= -1
	
	
	
	if current_station:
		if not visited and is_at_station:
			if Time.get_ticks_msec() - time_arrived_at_station > wait_time:
				print("leaving")
				# add new passengers
				var new_occupants = current_station.get_people(get_open_seats(), route)
				for occupant in new_occupants:
					occupants.append(occupant)
				update_occupants_label()
				# leave
				speed = top_speed
				visited = true
				is_at_station = false

	# if there is no station in range
	#if !current_station:
		#for station in route.stations:
			#if global_position.distance_to(station.global_position) < 80:
				#acceleration = (pow(speed, 2)) / (2 * global_position.distance_to(station.global_position))
				#
				#if station != current_station:
					#current_station = station
					#print("station sighted!")
					#var marker = Sprite2D.new()
					#marker.texture = load("res://assets/station.svg")
					#marker.global_position = global_position
					#marker.scale = Vector2(.3, .3)

	# if there is a station in range
	#if current_station:
		#var distance_to_station = global_position.distance_to(current_station.global_position)
		# arrived
		#if not visited and distance_to_station < (parent.get_progress() + change / 4):
			




				
				#if time_arrived_at_station == -1:
					##print("SETTING STATION ARRIVAL TIME")
					#time_arrived_at_station = Time.get_ticks_msec()
					#wait_time = current_station.get_wait_time(get_open_seats())
				#elif Time.get_ticks_msec() - time_arrived_at_station > wait_time:
					#acceleration = ((pow(top_speed, 2)) / (2 * 80))
					#visited = true
					#print("SETTING VISITED TO TRUE")

				#speed = 0
				#var new_occupants = current_station.get_people(get_open_seats(), route)
				#for occupant in new_occupants:
					#occupants.append(occupant)
				#update_occupants_label()

		
		
		
		#speed += acceleration * delta
		#if speed > top_speed:
			##print("error! speed is going in the wrong direction. current speed: " + str(speed) + " top speed: " + str(top_speed))
			#speed = top_speed
		
		#if not visited:

			#if global_position.distance_to(current_station.global_position) <= 10:
				#visited = true
				#if time_arrived_at_station == -1:
					##print("SETTING STATION ARRIVAL TIME")
					#time_arrived_at_station = Time.get_ticks_msec()
					#wait_time = current_station.get_wait_time(get_open_seats())
				#elif Time.get_ticks_msec() - time_arrived_at_station > wait_time:
					#acceleration = ((pow(top_speed, 2)) / (2 * 80))
					#visited = true
					##print("SETTING VISITED TO TRUE")
#
				##speed = 0
				#var new_occupants = current_station.get_people(get_open_seats(), route)
				#for occupant in new_occupants:
					#occupants.append(occupant)
				#update_occupants_label()



		#elif visited:			
			#if global_position.distance_to(current_station.global_position) > 80:
				#print("station out of range")
				#current_station = null
				#print(current_station)
				#visited = false
				#time_arrived_at_station = -1
				#speed = top_speed
				#acceleration = 0
				
	var new_progress = parent.get_progress() + change
	parent.set_progress(new_progress)



func approaching_station(station):
	if route.has_station(station):
		print("Now in the range of station: " + station.name)
		current_station = station
		
		var marker = Sprite2D.new()
		marker.texture = load("res://assets/station.svg")
		marker.global_position = global_position
		marker.scale = Vector2(.3, .3)

func left_station(station):
	if route.has_station(station):
		print("Now leaving the range of station: " + station.name)
		current_station = null
		visited = false
		time_arrived_at_station = -1
		speed = top_speed

func at_station(station):
	print("arrived at a a station!")
	time_arrived_at_station = Time.get_ticks_msec()
	wait_time = current_station.get_wait_time(get_open_seats())
	print(wait_time)
	is_at_station = true
	speed = 0


func update_occupants_label():
	$Label.text = str(len(occupants))

func set_route_closed(value: bool):
	route_closed = value

func get_open_seats():
	return max_occupancy - len(occupants)
