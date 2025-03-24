extends Area2D

var target_station

# defines person
var dream_station
var position_goal
var distance_walked
var speed

var initialized = false
var left_stations = false

# this should only be run for people being created the first time
func initialize():
	speed = randf_range(20, 30)
	target_station = Stations.find_closest_station(get_global_position())
	distance_walked = Stations.get_distance(get_global_position(), target_station.get_global_position())
	if global_position.x < target_station.position.x:
		get_node("AnimatedSprite").scale.x = -1
	pick_person_icon()
	
	initialized = true

func set_position_goal(global_pos: Vector2):
	# could cause a problem if the dream station is the closest station
	position_goal = global_pos
	dream_station = Stations.find_closest_station(position_goal)
	distance_walked += Stations.get_distance(position_goal, dream_station.get_global_position())

func recreate_person(info, pos: Vector2):
	position_goal = info.position_goal
	speed = info.speed
	distance_walked = info.distance_walked
	global_position = pos
	if global_position.x < position_goal.x:
		get_node("AnimatedSprite").scale.x = -1
	pick_person_icon()

	initialized = true
	left_stations = true

func _process(delta: float) -> void:
	if not Game.paused and initialized:
		if left_stations:
			move_to(position_goal, delta)
		else:
			move_to(target_station.get_global_position(), delta)

func move_to(target_pos: Vector2, delta: float):
	var distance_remaining = Stations.get_distance(get_global_position(), target_pos)
	if distance_remaining < 5:
		# should only do this if 
		if left_stations:
			Game.add_coins_from_distance(distance_walked)
			queue_free()
		else:
			target_station.add_person(self)

	var target_position: Vector2 = target_pos
	var vel: Vector2 = target_position - get_global_position()
	
	vel = vel.normalized()
	set_global_position(get_global_position() + delta * speed * vel)

func joined_station():
	queue_free()

func get_dream_station():
	return dream_station

func pick_person_icon():
	var animations = get_node("AnimatedSprite").sprite_frames.get_animation_names()
	var random_animation = animations[randi_range(0, animations.size() - 1)]

	get_node("AnimatedSprite").call_deferred("play", random_animation)
