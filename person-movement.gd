extends Area2D

var target_station
@export var speed = .5

func _ready() -> void:
	target_station = Stations.find_closest_station(self)

func _process(delta: float) -> void:
	if target_station:
		move_to(target_station, delta)

func move_to(target, delta):
	var target_position = target.get_global_position()
	self.set_global_position(self.get_global_position().lerp(target_position, speed * delta))
