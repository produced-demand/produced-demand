extends Node


@onready var stations = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func add_station(station_node):
	stations.append(station_node)

func find_closest_station(person):
	var target = stations[0]
	var target_distance = get_distance(stations[0].get_global_position(), person.get_global_position())
	for station in stations:
		var distance = get_distance(station.get_global_position(), person.get_global_position())
		if distance < target_distance:
			print(str(station) + " : " +str(distance))
			target = station
			target_distance = distance
		else:
			print("not greater " + str(target_distance) + " " + str(distance))
	return target

func get_distance(first_position, second_position):
	return abs(sqrt((second_position.y - first_position.y) * (second_position.y - first_position.y) + (second_position.x - first_position.x) * (second_position.x - first_position.x))) 
