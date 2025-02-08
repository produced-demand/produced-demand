extends Node2D

var creating_path: bool = false
var current_path
var current_line

var bus_scene = preload("res://bus.tscn")

#===============================
# paths to do:
# live preview of placement
# actually make them show up in the correct place
#===============================

func _ready() -> void:
	global_position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start_create_path"):
		creating_path = not creating_path
		if creating_path:
			print("starting to create path...")
			create_path(get_viewport().get_camera_2d().get_global_mouse_position())
		else:
			print("...stopping to create path")
			var route_is_closed = add_point_to_path(get_viewport().get_camera_2d().get_global_mouse_position(), true)
			add_child(current_path)

			# remove after testing is done
			add_bus_to_route(current_path, route_is_closed)

	elif Input.is_action_just_pressed("left_click") and creating_path:
		add_point_to_path(get_viewport().get_camera_2d().get_global_mouse_position(), false)
	elif event is InputEventMouseMotion and creating_path:
		var points = current_line.get_points()
		points[-1] = get_viewport().get_camera_2d().get_global_mouse_position()
		current_line.set_points(points)



func create_path(start_position):
	var route = Path2D.new()
	current_path = route
	route.curve = Curve2D.new()
	route.curve.add_point(start_position)
	
	var line := Line2D.new()
	line.default_color = Color(.8, .8, .8)
	line.end_cap_mode = 2
	line.width = 6
	current_line = line
	line.add_point(start_position)
	line.add_point(start_position)

	add_child(line)


func add_point_to_path(point_position, final_point):
	var last_point = current_path.curve.get_baked_points()[-1]
	var same_spot = false
	## check if points are close
	if abs(last_point.x - point_position.x) <= 150 and abs(last_point.x - point_position.x) <= 150:
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

func add_bus_to_route(route, route_is_closed):
	var follow_path = PathFollow2D.new()
	var bus = bus_scene.instantiate()
	
	bus.set_route_closed(route_is_closed)
	
	follow_path.add_child(bus)
	route.add_child(follow_path)
