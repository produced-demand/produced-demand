extends Area2D

var target_station
var dream_station
var at_station: bool = false
var distance_walked
var speed

func _ready() -> void:
	speed = randf_range(20, 30)
	target_station = Stations.find_closest_station(self)
	distance_walked = Stations.get_distance(get_global_position(), target_station.get_global_position())
	generate_dream_station()

func _process(delta: float) -> void:
	if target_station and not at_station and not Game.paused:
		move_to(target_station, delta)

func move_to(target, delta):
	var distance_remaining = Stations.get_distance(get_global_position(), target_station.get_global_position())
	if distance_remaining < 5:
		at_station = true
		target_station.add_person(self)

	var target_position: Vector2 = target.get_global_position()
	var vel: Vector2 = target_position - get_global_position()
	
	vel = vel.normalized()
	set_global_position(get_global_position() + delta * speed * vel)

func joined_station():
	queue_free()

func generate_dream_station():
	dream_station = Stations.get_random_station_excluding(target_station)

func get_dream_station():
	return dream_station
