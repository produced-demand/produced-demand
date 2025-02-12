extends Node2D

var station_scene = preload("res://station.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.double_click == true:
		var camera = get_viewport().get_camera_2d()
		generate_station(camera.get_global_mouse_position())

func generate_station(new_position):
	if not Stations.can_add_station():
		return

	var station = station_scene.instantiate()
	station.position = new_position
	get_tree().get_root().add_child(station)
