extends Node2D

@export var max_routes: int = 4
var routes = 0

var creating_path: bool = false
var current_path
var current_line

var bus_scene = preload("res://bus.tscn")

func _ready() -> void:
	global_position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start_create_path"):
		var mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
		if Stations.get_index_of_station_at_position(mouse_position) != -1:
			creating_path = not creating_path
			if creating_path and routes < max_routes:
				routes += 1
				create_path(mouse_position)
			else:
				var route_is_closed = add_point_to_path(mouse_position, true)
				add_child(current_path)

				# remove after testing is done
				var bus = create_bus(route_is_closed)
				current_path.add_bus(bus)
				current_path.set_is_closed(route_is_closed)

	elif Input.is_action_just_pressed("left_click") and creating_path:
		add_point_to_path(get_viewport().get_camera_2d().get_global_mouse_position(), false)
	elif event is InputEventMouseMotion and creating_path:
		var points = current_line.get_points()
		points[-1] = get_viewport().get_camera_2d().get_global_mouse_position()
		current_line.set_points(points)



func create_path(start_position):
	var route = Path2D.new()
	current_path = route

	var route_script = load("res://scripts/route.gd")
	route.script = route_script
	
	var station_at_position = Stations.get_station_at_position(start_position)
	start_position = station_at_position.get_global_position()
	current_path.add_station(station_at_position)
	station_at_position.add_route(current_path)
	
	route.curve = Curve2D.new()
	route.curve.add_point(start_position)
	
	var line := Line2D.new()
	line.default_color = Color(randf(), randf(), randf())
	line.set_end_cap_mode(2)
	line.width = 6
	current_line = line
	line.add_point(start_position)
	line.add_point(start_position)

	route.initilize(line)
	add_child(line)


func add_point_to_path(point_position, final_point):
	var last_point = current_path.curve.get_baked_points()[0]
	var same_spot = false
	
	var station_at_position = Stations.get_station_at_position(point_position)
	if station_at_position:
		point_position = station_at_position.get_global_position()
		current_path.add_station(station_at_position)
		station_at_position.add_route(current_path)

	if final_point and abs(last_point.x - point_position.x) <= 25 and abs(last_point.x - point_position.x) <= 25:
		point_position = last_point
		same_spot = true
	
	current_path.curve.add_point(point_position)
	
	var points = current_line.get_points()
	points[-1] = point_position
	current_line.set_points(points)
	current_line.add_point(point_position)
	
	if final_point and same_spot:
		return true
	else:
		return false

func create_bus(route_is_closed):
	var follow_path = PathFollow2D.new()
	var bus = bus_scene.instantiate()
	bus.set_route_closed(route_is_closed)
	follow_path.add_child(bus)
	return follow_path
