extends Area2D

var people: int = 0
var dream_stations: Array

var routes: Array

func _ready() -> void:
	Stations.add_station(self)
	
	connect("area_entered", _something_in_station)
	$Nearby.connect("area_entered", _on_range_entered)
	$Nearby.connect("area_exited", _on_range_exited)

func add_person(person):
	people += 1
	if people > 400:
		# make wordless game over screen later
		print("max people reached! game over!")
		get_tree().paused = true
	dream_stations.append(person.get_dream_station())
	person.joined_station() # removes person
	update_occupants_label()
	
func update_occupants_label():
	get_node("Label").text = str(people)

func add_route(route):
	routes.append(route)
	
func take_people(people_amount, stations):
	print(people_amount)
	print(stations)

func get_wait_time(spots_available):
	var potential_passengers
	if spots_available < people:
		potential_passengers = spots_available
	else:
		potential_passengers = people
	return 400 + (potential_passengers * 300)

func get_people(amount_of_people: int, _route):
	var people_to_send: Array
	# for now just dump them all
	# can figure out where/how to/whether they should be dumped later
	for i in range(0, amount_of_people):
		if len(dream_stations) == 0:
			break
		people_to_send.append(dream_stations.pop_front())
	people -= len(people_to_send)
	update_occupants_label()
	return people_to_send

func deliver_people(_peoples_dreams: Array):
	# will determine whether this station is their dream, if not add to wait
	pass



func _on_range_entered(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.approaching_station(self)

func _on_range_exited(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.left_station(self)

func _something_in_station(area):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		bus.at_station(self)
