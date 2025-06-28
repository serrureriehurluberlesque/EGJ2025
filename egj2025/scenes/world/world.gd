extends Control

var plant_ = preload("res://scenes/plant/plant.tscn")
var cop_ = preload("res://scenes/cop/cop.tscn")

var graines_rouges = load("res://scenes/world/assets/sacgrainesrouge_small.png")
var graines_bleues = load("res://scenes/world/assets/sacgrainesbleu_small.png")
var secateur = load("res://scenes/world/assets/secateur.png")
var arrosoir = load("res://scenes/world/assets/arrosoir_small.png")

var cageot = load("res://scenes/world/assets/cageot.png")
var cageot_select = load("res://scenes/world/assets/cageot_select.png")


const EARTH_TILES_ATLAS_COORDS = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(0,2),
	Vector2i(1,2),
]

const SEED_COST = 1

enum Mode {PLANT_RED_MODE, PLANT_BLUE_MODE, CUT_MODE, GROW_MODE}

var plants = {}
var moneyy = 10
var current_mode: Mode
var selected_button: TextureButton

func _ready():
	display_moneyy()
	$CopTimer.start()
	plant_blue_mode()

func _input(event):
	if event.is_action_pressed("activate"):
		var map_coords = $Map.local_to_map(event.position)
		
		if (current_mode == Mode.PLANT_RED_MODE or current_mode == Mode.PLANT_BLUE_MODE) and can_plant(map_coords):
			$Map.set_cell(map_coords, 2, Vector2i(2,1))
			var new_plant = plant_.instantiate()
			new_plant.position = $Map.map_to_local(map_coords)
			new_plant.z_index = map_coords[1]
			new_plant.connect("cutted", harvest_plant.bind(map_coords))
			
			if current_mode == Mode.PLANT_BLUE_MODE:
				new_plant.is_legal = true
				
			add_child(new_plant)
			plants[map_coords] = new_plant
			
			# Update moneyy
			self.moneyy -= SEED_COST
			display_moneyy()

	elif event.is_action_pressed("plant_blue_mode"):
		plant_blue_mode()
	elif event.is_action_pressed("plant_red_mode"):
		plant_red_mode()
	elif event.is_action_pressed("cut_mode"):
		cut_mode()
	elif event.is_action_pressed("grow_mode"):
		grow_mode()

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_position = get_viewport().get_mouse_position()
		var map_coords = $Map.local_to_map(mouse_position)
		if current_mode == Mode.CUT_MODE:
			if map_coords in plants.keys():
				plants[map_coords].cut(delta)
		elif current_mode == Mode.GROW_MODE:
			if map_coords in plants.keys():
				plants[map_coords].grow(delta)
			$Eau.set_position(mouse_position)
			$Eau.arrose += delta
		
func can_plant(map_coords: Vector2i):
	return $Map.get_cell_atlas_coords(map_coords) in EARTH_TILES_ATLAS_COORDS \
		and map_coords not in plants.keys() \
		and self.moneyy >= SEED_COST
		
func harvest_plant(price, coords):
	plants.erase(coords)
	$Map.set_cell(coords, 2, EARTH_TILES_ATLAS_COORDS[randi() % 4])
	self.moneyy += price
	display_moneyy()

func display_moneyy():
	$MoneyyLabel.text = "Money: %d$" % moneyy

func plant_blue_mode():
	current_mode = Mode.PLANT_BLUE_MODE
	Input.set_custom_mouse_cursor(graines_bleues)
	select_button(%PBButton)
	
func plant_red_mode():
	current_mode = Mode.PLANT_RED_MODE
	Input.set_custom_mouse_cursor(graines_rouges)
	select_button(%PRButton)
	
func cut_mode():
	current_mode = Mode.CUT_MODE
	Input.set_custom_mouse_cursor(secateur)
	select_button(%CButton)
	
func grow_mode():
	current_mode = Mode.GROW_MODE
	Input.set_custom_mouse_cursor(arrosoir)
	select_button(%WCButton)
	
func select_button(button_pressed):
	button_pressed.texture_normal = cageot_select
	if selected_button:
		selected_button.texture_normal = cageot
	selected_button = button_pressed
	
func _on_cop_timer_timeout() -> void:
	var new_cop = cop_.instantiate()
	new_cop.position = $CopSpawn.position
	add_child(new_cop)
	$CopTimer.start()
