extends Node2D

var parent
var reverse: bool = false
var route_closed: bool

func _ready() -> void:
	parent = get_parent()
	parent.progress_ratio = int(randf())



func _process(delta: float) -> void:
	if parent is PathFollow2D:
		var change = 100 * delta

		if not route_closed:
			if parent.get_progress_ratio() >= .99:
				reverse = true
			elif parent.get_progress_ratio() <= .01:
				reverse = false
			if reverse:
				change *= -1
			
		var new_progress = parent.get_progress() + change
		parent.set_progress(new_progress)

func set_route_closed(value: bool):
	route_closed = value
