extends Node2D

var road_node_scene = preload("res://road_node.tscn")

func create_map_nodes(map_data):
	print("creating map nodes...")
	var i = 0
	for node in map_data:
		if i > 10000:
			break
		var obj = map_data[node]
		generate_road_node(obj.x, obj.y)
		i += 1



func generate_road_node(x, y):
	var road_node = road_node_scene.instantiate()
	road_node.position = Vector2(x * 10000, y * 100 * cos(51.5))
	print(Vector2(x * 100, y))
	print(road_node.global_position)
	add_child(road_node)
