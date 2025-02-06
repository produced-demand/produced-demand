extends Node2D

func create_map(map_data):
	print("creating map nodes...")
	var i = 0
	const scale = 100
	for node in map_data:
		var obj = map_data[node]
		for next in obj[2]:
			var line = Line2D.new()
			line.width = 1
			line.default_color = Color(1, 0, 0)
			line.add_point(Vector2(obj[0] / scale, obj[1] / scale))
			line.add_point(Vector2(map_data[next][0] / scale, map_data[next][1] / scale))
			add_child(line)
		i += 1
