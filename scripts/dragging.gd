extends Node2D

var mouse_down: bool = false
var dragging: bool = false

var x_offset
var y_offset

var callback: Callable = placeholder

enum Shape {
	SQUARE,
	CIRCLE
}
var shape = Shape.SQUARE
var width
var height
var radius

var can_move = true
var data

func _ready():
	if self.get_class() == "Sprite2D":
		width = self.texture.get_width()
		height = self.texture.get_height()
	else:
		width = get_child(0).shape.radius
		height = get_child(0).shape.radius


func _process(delta: float) -> void:
	var mouse_was_down = mouse_down

	if Input.is_action_pressed("left_click") and Game.paused:
		mouse_down = true
	else:
		mouse_down = false

	if mouse_down:
		var mouse_pos = get_global_mouse_position()
		if not mouse_was_down:
			if shape == Shape.SQUARE and global_position.x - width / 2 < mouse_pos.x and mouse_pos.x < global_position.x + width / 2 and global_position.y - height / 2 < mouse_pos.y and mouse_pos.y < global_position.y + height / 2:
				start_dragging(mouse_pos)
			if shape == Shape.CIRCLE and global_position.distance_to(mouse_pos) < radius:
				start_dragging(mouse_pos)
		if dragging:
			global_position.x = mouse_pos.x - x_offset
			global_position.y = mouse_pos.y - y_offset
			callback.call({
				"pos": global_position,
				"data": data,
			})
	elif mouse_was_down:
		dragging = false

func start_dragging(mouse_pos):
	dragging = true
	x_offset = mouse_pos.x - global_position.x
	y_offset = mouse_pos.y - global_position.y

func placeholder(input):
	pass

func set_function(function):
	callback = function

func set_shape(new_shape: Shape):
	shape = new_shape

func set_radius(new_radius):
	radius = new_radius

func set_data(new_data):
	data = new_data
