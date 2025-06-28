extends Node2D

var plant_ = preload("res://scenes/plant/plant.tscn")

const EARTH_TILES_ATLAS_COORDS = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(0,2),
	Vector2i(1,2),
]

const SEED_COST = 1

enum Mode {PLANT_MODE, CUT_MODE, WATER_MODE}

const mode_strs = {
	Mode.PLANT_MODE: "PLANTER",
	Mode.CUT_MODE: "COUPER",
}

var plants = {}
var moneyy = 10
var current_mode = Mode.PLANT_MODE

func _ready():
	display_moneyy()
	display_mode()

func _input(event):
	if event.is_action_pressed("activate"):
		var map_coords = $Map.local_to_map(event.position)
		
		if current_mode == Mode.PLANT_MODE and can_plant(map_coords):
			$Map.set_cell(map_coords, 2, Vector2i(2,1))
			var new_plant = plant_.instantiate()
			new_plant.position = $Map.map_to_local(map_coords)
			new_plant.z_index = map_coords[1]
			new_plant.connect("cutted", harvest_plant.bind(map_coords))
			add_child(new_plant)
			plants[map_coords] = new_plant
			
			# Update moneyy
			self.moneyy -= SEED_COST
			display_moneyy()

	elif event.is_action_pressed("cut_mode"):
		current_mode = Mode.CUT_MODE
		display_mode()
	elif event.is_action_pressed("plant_mode"):
		current_mode = Mode.PLANT_MODE
		display_mode()

func _physics_process(delta: float) -> void:
	if current_mode == Mode.CUT_MODE and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_position = get_viewport().get_mouse_position()
		var map_coords = $Map.local_to_map(mouse_position)
		if map_coords in plants.keys():
			plants[map_coords].cut(delta)
		
func can_plant(map_coords: Vector2i):
	return $Map.get_cell_atlas_coords(map_coords) in EARTH_TILES_ATLAS_COORDS \
		and map_coords not in plants.keys() \
		and self.moneyy >= SEED_COST
		
func harvest_plant(price, coords):
	plants.erase(coords)
	self.moneyy += price
	display_moneyy()

func display_moneyy():
	$MoneyyLabel.text = "Money: %d$" % moneyy

func display_mode():
	$ModeLabel.text = "Mode: %s" % mode_strs[current_mode]
