extends Node2D

var max_routes: int = 6
var routes: int = 0

var creating_route: bool = false
var current_route
var current_line

var bus_scene = preload("res://bus.tscn")

func _ready() -> void:
	global_position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start_create_route"):
		var mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
		if creating_route:
			var route_finished: bool = add_point_to_route(mouse_position, true)
			if route_finished:
				routes += 1
				add_child(current_route)

				# remove when manually adding buses is implemented
				var bus = create_bus(current_route.get_is_closed())
				current_route.add_bus(bus)
				
				Stations.set_route_being_created(false)
				Game.hud.toggle_creating_route_indicator()

				# remove route creation stuff
				creating_route = false
				current_route = null
				current_line = null
		else:
			var is_station_at_position = Stations.get_index_of_station_at_position(mouse_position) != -1
			if is_station_at_position and routes < max_routes:
				creating_route = true
				create_route(mouse_position)
				Stations.set_route_being_created(true)
				Game.hud.toggle_creating_route_indicator()
	elif Input.is_action_just_pressed("left_click") and creating_route:
		add_point_to_route(get_viewport().get_camera_2d().get_global_mouse_position(), false)
	elif event is InputEventMouseMotion and creating_route:
		var points = current_line.get_points()
		points[-1] = get_viewport().get_camera_2d().get_global_mouse_position()
		current_line.set_points(points)

func cancel_route_creation():
	current_route.queue_free()
	current_line.queue_free()
	
	Stations.set_route_being_created(false)
	Game.hud.toggle_creating_route_indicator()

	creating_route = false
	current_route = null
	current_line = null

func create_route(start_position):
	var route = Path2D.new()
	var route_script = load("res://scripts/route.gd")
	route.script = route_script
	current_route = route

	var station_at_position = Stations.get_station_at_position(start_position)
	start_position = station_at_position.get_global_position()
	current_route.add_station(station_at_position)
	station_at_position.add_route(current_route)

	route.curve = Curve2D.new()
	route.curve.add_point(start_position)
	route.add_point_at_position(start_position, true)

	# live preview
	var line = Line2D.new()
	line.default_color = Color(randf(), randf(), randf())
	line.set_end_cap_mode(2)
	line.width = 6
	current_line = line
	line.add_point(start_position)
	line.add_point(start_position)

	route.initilize(line)
	add_child(line)


# returns bool, true if point created
func add_point_to_route(point_position, is_last_point):
	var points_on_route = current_route.curve.get_baked_points()
	var first_point = points_on_route[0]
	var last_point = points_on_route[-1]

	var closes_loop = false

	# if in the same position as the last point
	if abs(last_point.x - point_position.x) <= 5 and abs(last_point.x - point_position.x) <= 5:
		print("too close to last")
		return false
	# if in the same position as the first point and this is the final point
	if is_last_point and abs(first_point.x - point_position.x) <= 25 and abs(first_point.x - point_position.x) <= 25:
		closes_loop = true
	# if the new point is the same as the only other point
	if len(points_on_route) == 1 and first_point == point_position:
		return false
		
	var station_at_position = Stations.get_station_at_position(point_position)
	if station_at_position:
		point_position = station_at_position.global_position
		current_route.add_station(station_at_position)
		station_at_position.add_route(current_route)
	elif is_last_point:
		return false

	current_route.curve.add_point(point_position)
	current_route.add_point_at_position(point_position, false if station_at_position == null else true)
	var points = current_line.get_points()
	points[-1] = point_position
	current_line.set_points(points)
	current_line.add_point(point_position)

	if is_last_point:
		current_route.set_is_closed(closes_loop)

	return true


func create_bus(route_is_closed):
	var follow_path = PathFollow2D.new()
	var bus = bus_scene.instantiate()
	bus.set_route_closed(route_is_closed)
	follow_path.add_child(bus)
	return follow_path
