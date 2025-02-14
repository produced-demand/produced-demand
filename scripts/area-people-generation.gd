extends Node2D

var person_scene = preload("res://person.tscn")

@export var interval = 1000
var last_ran = Time.get_ticks_msec()


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec()
	if now - last_ran > interval and not Game.paused:
		last_ran = now
		if randi_range(1, 3) == 1:
			generate_person()


func generate_person():
	var person = person_scene.instantiate()

	var shape = get_tree().get_root().get_node("level").get_node("Areas").get_node("Area2D").get_node("CollisionShape2D").shape.get_rect().size

	var person_size = person.get_node("CollisionShape2D").shape.get_rect().size
	var x_pos = randf_range(0, shape.x - person_size.x)
	var y_pos = randf_range(0, shape.y - person_size.y)

	person.global_position = Vector2(x_pos, y_pos)
	
	add_child(person)
