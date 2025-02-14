extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.set_hud(self)
	get_node("End").hide()

func set_score(score):
	get_node("ScoreLabel").text = str(score)

func show_end():
	get_node("End").show()

# start button pressed
func _on_start_button_pressed() -> void:
	get_node("Start").hide()
	Game.start()
