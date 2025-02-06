extends Area2D

var people: Array

func _ready() -> void:
	Stations.add_station(self)

func add_person(person):
	people.append(person)
	person.joined_station()
	update_occupants_label()
	
func update_occupants_label():
	get_node("Label").text = str(len(people))
