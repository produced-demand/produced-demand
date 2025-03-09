extends CanvasLayer


func _ready() -> void:
	Game.set_hud(self)
	get_node("End").hide()
	get_node("Indicators").get_node("CreatingRouteIndicator").hide()

func set_score(score):
	get_node("Info").get_node("Score").get_node("ScoreLabel").text = str(score)

func show_end():
	get_node("End").show()

func toggle_creating_route_indicator():
	if get_node("Indicators").get_node("CreatingRouteIndicator").is_visible():
		get_node("Indicators").get_node("CreatingRouteIndicator").hide()
	else:
		get_node("Indicators").get_node("CreatingRouteIndicator").show()

# start button pressed
func _on_start_button_pressed() -> void:
	get_node("Start").hide()
	Game.start()

func _on_cancel_route_button_pressed() -> void:
	get_tree().get_root().get_node("level").get_node("Paths").cancel_route_creation()


func _on_play_again_pressed() -> void:
	Game.reset()
	get_tree().reload_current_scene()

func update_bus_label():
	print("updaing label")
	get_node("Resources").get_node("Stations").get_node("Label").text = str(Stations.get_station_count()) + "/" + str(Game.get_max_stations());

func update_route_label():
	print("updaing label")
	get_node("Resources").get_node("Routes").get_node("Label").text = str(Game.get_route_count()) + "/" + str(Game.get_max_routes());

func _on_pause_button_pressed() -> void:
	Game.toggle_pause()


func _on_zoom_in_pressed() -> void:
	Game.camera.zoom_in()
func _on_zoom_out_pressed() -> void:
	Game.camera.zoom_out()
