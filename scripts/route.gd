extends Path2D

var stations: Array
var visual_line
var is_closed

func initilize(visual_line_element):
	self.visual_line = visual_line_element

func set_is_closed(is_closed_input):
	self.is_closed = is_closed_input

func get_is_closed():
	return is_closed

func add_station(station):
	stations.append(station)

func add_bus(bus):
	add_child(bus)

func has_station(station):
	return stations.has(station)

func get_station_count():
	return len(stations)
