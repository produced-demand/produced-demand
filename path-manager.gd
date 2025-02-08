extends Node2D

var creating_path: bool = false
var current_path

var bus_scene = preload("res://bus.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start_create_path"):
		creating_path = not creating_path
		if creating_path:
			print("starting to create path...")
			create_path(get_viewport().get_camera_2d().get_global_mouse_position())
		else:
			print("...stopping to create path")
			add_point_to_path(get_viewport().get_camera_2d().get_global_mouse_position())
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
			add_bus_to_route(current_path)


	elif Input.is_action_just_pressed("left_click") and creating_path:
		add_point_to_path(get_viewport().get_camera_2d().get_global_mouse_position())


func create_path(position):
	var line = Path2D.new()
	current_path = line
	line.curve = Curve2D.new()
	line.curve.add_point(position)

func add_point_to_path(position):
	current_path.curve.add_point(position)

func add_bus_to_route(route):
	var follow_path = PathFollow2D.new()
	var bus = bus_scene.instantiate()
	
	follow_path.add_child(bus)
	route.add_child(follow_path)
	print("added bus")
