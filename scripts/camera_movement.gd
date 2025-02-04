extends Camera2D

@onready var zoom_in_multiplier = 1.05
@onready var zoom_out_multiplier = 0.95
@onready var zoom_speed = 10
@onready var zoom_target : Vector2
@onready var pan_speed = 350

var drag_start_mouse_position
var drag_start_camera_position
var is_dragging : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom_target = zoom
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_zoom(delta)
	simple_pan(delta)
	click_and_pan()

func scroll_zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom_target *= zoom_in_multiplier
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom_target *= zoom_out_multiplier

	if zoom_target.x > 5:
		zoom_target.x = 5
		zoom_target.y = 5;
	if zoom_target.x < .7:
		zoom_target.x = .7
		zoom_target.y = .7
	
	zoom = zoom.lerp(zoom_target, zoom_speed * delta)

func simple_pan(delta):
	var move_amount = Vector2.ZERO

	if Input.is_action_pressed("camera_move_up"):
		move_amount.y -= 1
	if Input.is_action_pressed("camera_move_down"):
		move_amount.y += 1
	if Input.is_action_pressed("camera_move_left"):
		move_amount.x -= 1
	if Input.is_action_pressed("camera_move_right"):
		move_amount.x += 1
		
	move_amount.normalized()
	position += move_amount * delta * pan_speed * (1 / zoom.x)

func click_and_pan():
	if not is_dragging and Input.is_action_just_pressed("camera_pan"):
		is_dragging = true
		drag_start_mouse_position = get_viewport().get_mouse_position()
		drag_start_camera_position = position
	if is_dragging and Input.is_action_just_released("camera_pan"):
		is_dragging = false
		
	if is_dragging:
		var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_position
		position = drag_start_camera_position - move_vector * (1 / zoom.x)
