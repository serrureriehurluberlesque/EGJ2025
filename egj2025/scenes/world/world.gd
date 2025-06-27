extends TileMapLayer

var plant_ = preload("res://scenes/plant/plant.tscn")

func _input(event):
	if event.is_action_pressed("activate"):
		var map_coords = self.local_to_map(event.position)
		self.set_cell(map_coords, 2, Vector2i(2,1))
		
		# TODO check si la cell est ok (terre + pas encore de plante à cet endroit)
		var new_plant = plant_.instantiate()
		new_plant.position = self.map_to_local(map_coords)
		add_child(new_plant)
