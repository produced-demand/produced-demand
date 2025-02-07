extends Node2D

func create_map(map_data):
	print("rendering map...")
	const map_scale = 100
	for way in map_data:
		var data = map_data[way]
		var line = Line2D.new()
		line.width = 2
		line.default_color = Color(0.7, 0.7, 0.7)
		for i in range(1, len(data), 2):
			line.add_point(Vector2((data[i] / map_scale) * 2, (data[i + 1] / map_scale) * 2))
		add_child(line)
