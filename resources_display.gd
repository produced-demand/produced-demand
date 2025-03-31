extends Control

var hud

func _ready() -> void:
	hud = get_parent()
	update_new_station_cost()
	update_new_route_cost()

func _on_buy_station_pressed() -> void:
	if Game.can_buy_station():
		Game.buy_station()
		hud.update_station_label()
		update_new_station_cost()

func _on_buy_route_pressed() -> void:
	if Game.can_buy_route():
		Game.buy_route()
		hud.update_route_label()
		update_new_route_cost()

func update_new_station_cost():
	get_node("BuyStation").get_node("Label").text = str(int(Game.resource_costs.station))
func update_new_route_cost():
	get_node("BuyRoute").get_node("Label").text = str(int(Game.resource_costs.route))

# UPDATE THE COSTS DISPLAY
# test buying works
