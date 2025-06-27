extends Node2D

var plant_ = preload("res://scenes/plant/plant.tscn")

const EARTH_TILES_ATLAS_COORDS = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(0,2),
	Vector2i(1,2),
]

const SEED_COST = 1

var plant_coords = []
var moneyy = 10

func _ready():
	update_moneyy()

func _input(event):
	if event.is_action_pressed("activate"):
		var map_coords = $Map.local_to_map(event.position)
		
		if $Map.get_cell_atlas_coords(map_coords) in EARTH_TILES_ATLAS_COORDS \
		and map_coords not in plant_coords \
		and self.moneyy >= SEED_COST:
			$Map.set_cell(map_coords, 2, Vector2i(2,1))
			var new_plant = plant_.instantiate()
			new_plant.position = $Map.map_to_local(map_coords)
			new_plant.z_index = map_coords[1]
			add_child(new_plant)
			plant_coords.append(map_coords)
			
			# Update moneyy
			self.moneyy -= SEED_COST
			update_moneyy()
			
			
func update_moneyy():
	$MoneyyLabel.text = "Money: %d$" % self.moneyy
