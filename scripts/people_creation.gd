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

			var person = generate_person(area_index.x, area_index.y)
			var rand_position = get_random_position_in_areas(area_indexs)
			person.set_position_goal(rand_position)

func get_random_position_in_areas(area_indexs: Array):
	var area_index = area_indexs[randi_range(0, len(area_indexs) - 1)]
	var y = area_index.x
	var x = area_index.y

	var area = areas.areas_array[y][x]

	var x_pos = randf_range(0, area_size)
	var y_pos = randf_range(0, area_size)
	
	var rand_position = Vector2(x_pos + area.global_position.x, y_pos + area.global_position.y)
	return rand_position

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

func generate_person(y: int, x: int):
	var area = areas.areas_array[y][x]
	
	var person = person_scene.instantiate()

	var x_pos = randf_range(0, area_size)
	var y_pos = randf_range(0, area_size)

	person.global_position = Vector2(x_pos + area.global_position.x - areas.get_position_for_area(y, x).x, y_pos + area.global_position.y - areas.get_position_for_area(y, x).y)
	area.add_child(person)
	person.initialize()
	return person

func regenerate_person(pos: Vector2, info):
	var person = person_scene.instantiate()
	person.recreate_person(info, pos)
	get_tree().get_root().get_node("level").get_node("Areas").call_deferred("add_child", person)
	person.pick_person_icon()
