extends Path2D

var stations: Array
var visual_line
var is_closed

func initilize(visual_line):
	self.visual_line = visual_line

func set_is_closed(is_closed):
	self.is_closed = is_closed

func add_station(station):
	stations.append(station)

func add_bus(bus):
	add_child(bus)
