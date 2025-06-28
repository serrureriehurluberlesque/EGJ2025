extends Control

var plant_ = preload("res://scenes/plant/plant.tscn")
var cop_ = preload("res://scenes/cop/cop.tscn")
var maf_ = preload("res://scenes/cop/maf.tscn")
var mec_ = preload("res://scenes/cop/mec.tscn")

var graines_rouges = load("res://scenes/world/assets/sacgrainesrouge_small.png")
var graines_bleues = load("res://scenes/world/assets/sacgrainesbleu_small.png")
var secateur = load("res://scenes/world/assets/secateur_small.png")
var arrosoir = load("res://scenes/world/assets/arrosoir_small.png")

var cageot = load("res://scenes/world/assets/cageot.png")
var cageot_select = load("res://scenes/world/assets/cageot_select.png")


const EARTH_TILES_ATLAS_COORDS = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(0,2),
	Vector2i(1,2),
]

const EARTH_PLANTED_ATLAS_COORDS = [
	Vector2i(2,1),
	Vector2i(2,2),
]

const SEED_COST = 5.0
const WAIT_COP= 40.0
const RATIO_MAF = 0.3
const RATIO_MEC = 0.0

enum Mode {PLANT_RED_MODE, PLANT_BLUE_MODE, CUT_MODE, GROW_MODE}

var plants = {}
var total_cop = 0
var moneyy = 100.0
var current_mode: Mode
var selected_button: TextureButton
var surbrillanced_tile_coords: Vector2i


func _ready():
	display_moneyy()
	$CopTimer.start()
	plant_blue_mode()

func _input(event):
	if event.is_action_pressed("plant_blue_mode"):
		plant_blue_mode()
	elif event.is_action_pressed("plant_red_mode"):
		plant_red_mode()
	elif event.is_action_pressed("cut_mode"):
		cut_mode()
	elif event.is_action_pressed("grow_mode"):
		grow_mode()

func _physics_process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var map_coords = $Map.local_to_map(mouse_position)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_mode == Mode.CUT_MODE:
			if map_coords in plants.keys():
				plants[map_coords].cut(delta)
		elif current_mode == Mode.GROW_MODE:
			if map_coords in plants.keys():
				plants[map_coords].grow(delta)
			$Eau.set_position(mouse_position)
			$Eau.arrose += delta
		elif (current_mode == Mode.PLANT_RED_MODE or current_mode == Mode.PLANT_BLUE_MODE) and can_plant(map_coords):
			$Map.set_cell(map_coords, 2, EARTH_PLANTED_ATLAS_COORDS[randi() % EARTH_PLANTED_ATLAS_COORDS.size()])
			var new_plant = plant_.instantiate()
			new_plant.position = $Map.map_to_local(map_coords)
			new_plant.z_index = map_coords[1]
			new_plant.connect("cutted", harvest_plant.bind(map_coords))
			
			if current_mode == Mode.PLANT_BLUE_MODE:
				new_plant.is_legal = true
				
			$Plants.add_child(new_plant)
			plants[map_coords] = new_plant
			
			# Update moneyy
			self.moneyy -= SEED_COST
			display_moneyy()

			
	if map_coords != surbrillanced_tile_coords:
	#if map_coords in plants.keys() and map_coords != surbrillanced_tile_coords:
		#var tile_data = $Map.get_cell_tile_data(map_coords)
		#tile_data.set_modulate(Color(1.2, 1.2, 1.2, 1))
		if map_coords in plants.keys():
			plants[map_coords].start_highlight()

		if surbrillanced_tile_coords and surbrillanced_tile_coords in plants.keys():
			#$Map.get_cell_tile_data(surbrillanced_tile_coords).set_modulate(Color(1, 1, 1, 1))
			plants[surbrillanced_tile_coords].stop_highlight()
		surbrillanced_tile_coords = map_coords
		
func can_plant(map_coords: Vector2i):
	return $Map.get_cell_atlas_coords(map_coords) in EARTH_TILES_ATLAS_COORDS \
		and map_coords not in plants.keys() \
		and self.moneyy >= SEED_COST
		
func harvest_plant(price, coords):
	plants.erase(coords)
	$Map.set_cell(coords, 2, EARTH_TILES_ATLAS_COORDS[randi() % EARTH_TILES_ATLAS_COORDS.size()])
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
	Input.set_custom_mouse_cursor(arrosoir, 0, Vector2(0, 58))
	select_button(%WCButton)
	
func select_button(button_pressed):
	button_pressed.texture_normal = cageot_select
	if selected_button and selected_button != button_pressed:
		selected_button.texture_normal = cageot
	selected_button = button_pressed
	
func _on_cop_timer_timeout() -> void:
	var look_ilegal = true
	var new_cop
	
	if total_cop <= 2 or total_cop > 3 and randf() < RATIO_MEC:
		new_cop = mec_.instantiate()
	elif total_cop == 3 or randf() < RATIO_MAF:
		new_cop = maf_.instantiate()
		look_ilegal = false
	else:
		new_cop = cop_.instantiate()
	
	var n = 0
	for p in $Plants.get_children():
		if (look_ilegal and not p.is_legal) or (not look_ilegal and p.is_legal):
			n += 1
			n *= 0.8
			if not look_ilegal:
				n *= 0.5
	
	n = round(max(0.6 + total_cop / 3.0, n + total_cop / 3.0))
	
	new_cop.position = $CopSpawn.position
	new_cop.to_be_seen = n
	new_cop.connect("bust", show_game_over)
	add_child(new_cop)
	$CopTimer.wait_time = max(1.5, WAIT_COP * 0.9 ** total_cop * (0.75 + randf() / 2.0))
	total_cop += 1
	$CopTimer.start()
	await get_tree().create_timer(4.5).timeout
	$Player.start_talking(n)
	
func show_game_over() -> void:
	await get_tree().create_timer(3).timeout
	# TODO pause game
	set_pause_subtree(self, true)
	Input.set_custom_mouse_cursor(null)
	$GameOverPanel.show()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
func set_pause_subtree(root: Node, pause: bool) -> void:
	var process_setters = ["set_process",
	"set_physics_process",
	"set_process_input",
	"set_process_unhandled_input",
	"set_process_unhandled_key_input",
	"set_process_shortcut_input",]
	
	for setter in process_setters:
		root.propagate_call(setter, [!pause])
