extends Node2D

var creating_path: bool = false
var current_path

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

			var line := Line2D.new()
			line.default_color = Color(.8, .8, .8)
			line.end_cap_mode = 2
			line.width = 6
			var points = current_path.curve.get_baked_points()
			for point in points:
				line.add_point(point)

			add_child(line)

			# remove after testing is done
			add_bus_to_route(current_path, route_is_closed)


	elif Input.is_action_just_pressed("left_click") and creating_path:
		add_point_to_path(get_viewport().get_camera_2d().get_global_mouse_position(), false)


func create_path(start_position):
	var line = Path2D.new()
	current_path = line
	line.curve = Curve2D.new()
	line.curve.add_point(start_position)

func add_point_to_path(point_position, final_point):
	var last_point = current_path.curve.get_baked_points()[-1]
	var same_spot = false
	## check if points are close
	if abs(last_point.x - point_position.x) <= 50 and abs(last_point.x - point_position.x) <= 50:
		same_spot = true
	
	current_path.curve.add_point(point_position)
	
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
