extends Area2D

var people: int
var dream_stations: Array

func _ready() -> void:
	Stations.add_station(self)

func add_person(person):
	people += 1
	if people > 1000:
		print("max people reached! game over!")
		get_tree().paused = true
	dream_stations.append(person.get_dream_station())
	print("dream just extracted: " + str(person.get_dream_station()))
	person.joined_station() # removes person
	update_occupants_label()
	
func update_occupants_label():
	get_node("Label").text = str(people)
