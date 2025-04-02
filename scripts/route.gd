extends Path2D

var stations: Array
var visual_line
var is_closed
var points: Array
var buses: Array

func initilize(visual_line_element):
	self.visual_line = visual_line_element

func set_is_closed(is_closed_input):
	self.is_closed = is_closed_input

func get_is_closed():
	return is_closed

func add_station(station):
	#if not station in stations:
	stations.append(station)

func add_bus(bus):
	add_child(bus)

func register_bus(bus):
	buses.append(bus)

func has_station(station):
	return stations.has(station)

func get_station_count():
	return len(stations)

func add_point_at_position(point, at_station):
	var handle = Sprite2D.new()
	handle.texture = load("res://assets/icons/move.svg")
	handle.global_position = point
	handle.scale = Vector2(.2, .2)
	handle.set_visible(true)
	add_child(handle)


	points.append({
		"position": handle.global_position,
		"atStation": at_station,
		"handle": handle
	})

	# add collider
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 20

	var area = Area2D.new()
	add_child(area)
	if not at_station:
		area.set_script(load("res://scripts/dragging.gd"))
		area.set_function(point_moved)
		area.set_radius(circle_shape.radius)
		area.set_shape(area.Shape.CIRCLE)
		area.set_data(len(points) - 1)

	var area_collision_shape = CollisionShape2D.new()
	area_collision_shape.shape = circle_shape
	area.global_position = point
	area.add_child(area_collision_shape)
	
	area.connect("area_entered", _on_bus_entered.bind(len(points) - 1))

func set_handles_visible(set_visible: bool):
	for point in points:
		point.handle.set_visible(set_visible)

func point_moved(obj):
	# for creating new route points (will also need to update last_item)
	var with_shift = Input.is_action_pressed("shift")
	
	if with_shift: # should not run every time
		# insert new point
		pass
	
	
	var new_position: Vector2 = obj.pos
	var point_index = obj.data

	self.curve.set_point_position(point_index, new_position)
	visual_line.set_point_position(point_index, new_position)
	points[point_index].position = new_position
	points[point_index].handle.set_global_position(new_position)
	
	Game.add_route_changed(self)
	
	for bus in buses:
		bus.set_to_progress_ratio()

func _on_bus_entered(area, point_index):
	if area.name == "BusCollider":
		var bus = area.get_parent()
		if bus.on_route(self):
			if self.get_next_point(bus.last_point, bus.reverse) == points[point_index]:
				bus.set_last_point(points[point_index])

func get_closest_point(pos):
	var closest = points[0]
	var target_distance = get_distance(points[0].position, pos)
	for point in points:
		var distance = get_distance(point.position, pos)
		if distance < target_distance:
			closest = point
			target_distance = distance
	return closest

func get_distance(first_position, second_position):
	return abs(first_position.distance_to(second_position))

func is_end_point(point):
	var index = points.find(point, 0)
	if index == 0 or index == len(points) - 1:
		return true
	else:
		return false

func get_next_point(point, reverse: bool):
	var index = points.find(point, 0)
	var next_index = (index + 1) if not reverse else (index - 1)
	if next_index >= len(points):
		next_index = 0
	if next_index < 0:
		next_index = len(points) - 1
	return points[next_index]

func get_next_point_with_station(point, reverse: bool):
	var index = points.find(point, 0)
	var next_index = (index + 1) if not reverse else (index - 1)
	if next_index >= len(points):
		next_index = 0
	if next_index < 0:
		next_index = len(points) - 1
	while not points[next_index].atStation:
		next_index = (next_index + 1) if not reverse else (next_index - 1)
		
		if next_index >= len(points):
			next_index = 0
		if next_index < 0:
			next_index = len(points) - 1

	return points[next_index]

func get_point_at_position(given_position):
	for point in points:
		if point.position == given_position:
			return point
	return null

func route_changed_update_buses():
	for bus in buses:
		bus.has_been_moved()
