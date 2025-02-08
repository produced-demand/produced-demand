extends Node2D

var parent

func _ready() -> void:
	parent = get_parent()
	parent.progress_ratio = int(randf())


func _process(delta: float) -> void:
	if parent is PathFollow2D:
		var new_progress = parent.get_progress() + 100 * delta
		parent.set_progress(new_progress)
