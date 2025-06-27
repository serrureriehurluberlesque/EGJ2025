extends TileMapLayer

var plant_ = preload("res://scenes/plant/plant.tscn")

const EARTH_TILES_ATLAS_COORDS = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(0,2),
	Vector2i(1,2),
]

var plant_coords = []

func _input(event):
	if event.is_action_pressed("activate"):
		var map_coords = self.local_to_map(event.position)
		
		print(self.get_cell_atlas_coords(map_coords))
		
		if self.get_cell_atlas_coords(map_coords) in EARTH_TILES_ATLAS_COORDS and map_coords not in plant_coords:
			self.set_cell(map_coords, 2, Vector2i(2,1))
			var new_plant = plant_.instantiate()
			new_plant.position = self.map_to_local(map_coords)
			new_plant.z_index = map_coords[1]
			add_child(new_plant)
			plant_coords.append(map_coords)
