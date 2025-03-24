extends Node2D

var area_scene = preload("res://area.tscn")

var areas_array = []

var last_tile_added = 0
var time_before = 18

var area_size = 250

func _ready() -> void:
	areas_array.resize(15)
	for i in range(0, len(areas_array)):
		var empty_array = []
		empty_array.resize(15)
		empty_array.fill(null)
		areas_array[i] = empty_array

	for i in range(6, 9):
		for j in range(6, 9):
			var area_position = get_position_for_area(i, j)
			areas_array[i][j] = generate_area(area_position)
	
	PeopleGenerator.register_areas_script(self)

func _process(_delta: float) -> void:
	if Game.paused:
		return
	if Game.get_time() > last_tile_added + time_before:
		last_tile_added = Game.get_time()
		time_before -= .3 # to increase speed of tile generation
		add_tile_in_closest_circle()


func add_tile_in_closest_circle():
	var radius = 2
	var spots_in_radius
	var found_spot = false
	while radius < floor(len(areas_array) / 2.0):
		spots_in_radius = get_items_in_radius(radius)
		var empty_spots = spots_in_radius.filter(func(item): return areas_array[item.x][item.y] == null)
		if len(empty_spots) > 0:
			spots_in_radius = empty_spots
			found_spot = true
			break
		radius += 1
	if not found_spot:
		return
	
	var random_spot = spots_in_radius[randi_range(0, len(spots_in_radius) - 1)]
	areas_array[random_spot.x][random_spot.y] = generate_area(get_position_for_area(random_spot.x, random_spot.y))

func get_items_in_radius(radius):
	var items = []
	var center = floor(len(areas_array) / 2.0)
	for i in range(center - radius, center + radius + 1):
		items.append(Vector2(i, center - radius)) # left
		items.append(Vector2(i, center + radius)) # right
		items.append(Vector2(center - radius, i)) # top
		items.append(Vector2(center + radius, i)) # bottom
	return items


func generate_area(pos):
	var area = area_scene.instantiate()
	area.global_position = pos
	add_child(area)
	return area

func get_position_for_area(i, j):
	var center_i = floor(len(areas_array) / 2)
	var center_j = floor(len(areas_array) / 2)

	var offset_i = i - center_i
	var offset_j = j - center_j

	var position_x = offset_j * area_size - area_size/2
	var position_y = offset_i * area_size - area_size/2

	return Vector2(position_x, position_y)
