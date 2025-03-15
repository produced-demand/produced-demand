extends Node

var areas
var person_scene = preload("res://person.tscn")

var last_ran = Time.get_ticks_msec()
var area_size = 250

func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec()
	if not Game.paused and now - last_ran > Game.people_creation_speed:
		last_ran = now

		var area_indexs = get_existing_area_indexs()
		for i in range(round(.5 * len(area_indexs))):
			var area_index = area_indexs[randi_range(0, len(area_indexs) - 1)]
			generate_person(area_index.x, area_index.y)

func register_areas_script(script):
	areas = script

func get_existing_area_indexs():
	var array = areas.areas_array
	var existing_indexs: Array
	for i in range(len(array)):
		for j in range(len(array)):
			if array[i][j] != null:
				existing_indexs.append(Vector2(i, j))
	return existing_indexs

func get_area_count():
	return len(get_existing_area_indexs())

func generate_person(y, x):
	var area = areas.areas_array[y][x]
	
	var person = person_scene.instantiate()

	var person_size = person.get_node("CollisionShape2D").shape.get_rect().size
	var x_pos = randf_range(0, area_size)
	var y_pos = randf_range(0, area_size)

	# error is here
	person.global_position = Vector2(x_pos + area.global_position.x - areas.get_position_for_area(y, x).x, y_pos + area.global_position.y - areas.get_position_for_area(y, x).y)
	
	area.add_child(person)
