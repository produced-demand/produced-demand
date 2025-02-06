extends Area2D

var people: int

func _ready() -> void:
	Stations.add_station(self)

func add_person(person):
	people += 1
	#person.quene_free() # remove - when destination stations are determined, the destination station should removed from the player and added to an array, and when a bus comes on the right track a new person will be generated with that goal 
	# old code: people.append(person);
	person.joined_station() # removes person now
	update_occupants_label()
	
func update_occupants_label():
	#get_node("Label").text = str(len(people))
	get_node("Label").text = str(people)
