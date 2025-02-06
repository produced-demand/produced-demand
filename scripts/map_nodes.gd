extends Node2D

var osm_way_scene = preload("res://osm_way.tscn")

func create_map_nodes(map_data):
	print("creating map nodes...")
	var i = 0
	for node in map_data:
		if i > 100000:
			break
		var obj = map_data[node]
		generate_road_node(obj[0], obj[1])
		i += 1



func generate_road_node(x, y):
	var osm_way = osm_way_scene.instantiate()
	osm_way.position = Vector2(x / 100, y / 100)
	add_child(osm_way)
