extends Area2D

var target_station
var at_station: bool = false
var speed

func _ready() -> void:
	speed = randf_range(70, 90)
	target_station = Stations.find_closest_station(self)

func _process(delta: float) -> void:
	if target_station and not at_station:
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
	#get_node("Sprite2D").visible = false
