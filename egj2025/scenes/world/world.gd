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
const RATIO_MAF = 0.0
const RATIO_MEC = 0.0

enum Mode {PLANT_RED_MODE, PLANT_BLUE_MODE, CUT_MODE, GROW_MODE}

var upgraded = {
	Mode.PLANT_RED_MODE: false,
	Mode.PLANT_BLUE_MODE: false,
	Mode.CUT_MODE: false,
	Mode.GROW_MODE: false,
}

var plants = {}
var total_cop = 0
var moneyy = 100.0
var displayed_moneyy = 100.0
var current_mode: Mode
var selected_button: TextureButton
var surbrillanced_tile_coords: Vector2i
var current_cursor: Texture2D

func _ready():
	display_moneyy()
	$CopTimer.start()
	plant_blue_mode()
	$Map.get_cell_tile_data(Vector2i(0,0)).z_index = 10
	
	if Global.first_time:
		toggle_menu()

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
	if moneyy >= 1000:
		for u in upgraded:
			upgraded[u] = true
	
	
	var mouse_position = get_viewport().get_mouse_position()
	var map_coordss = [$Map.local_to_map(mouse_position)]
	if upgraded[current_mode]:
		for v in [Vector2(-64, 0), Vector2(64, 0), Vector2(0, -64), Vector2(0, 64)]:
			map_coordss.append($Map.local_to_map(mouse_position + v))
	
	if upgraded[Mode.GROW_MODE]:
		$Eau.amount = 200
		$Eau.process_material.spread = 60.0
		$Eau.lifetime = 1.5
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_mode == Mode.CUT_MODE:
			for map_coords in map_coordss:
				if map_coords in plants.keys():
					plants[map_coords].cut(delta)
		elif current_mode == Mode.GROW_MODE:
			for map_coords in map_coordss:
				if map_coords in plants.keys():
					plants[map_coords].grow(delta)
			for map_coords in [map_coordss[0]]:
				$Eau.set_position(mouse_position)
				$Eau.arrose += delta
		elif (current_mode == Mode.PLANT_RED_MODE or current_mode == Mode.PLANT_BLUE_MODE):
			for map_coords in map_coordss:
				if can_plant(map_coords):
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
	
	for map_coords in [map_coordss[0]]:
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
	if moneyy > displayed_moneyy:
		$AnimationPlayer.play("cash")
	$MoneyyLabel.text = "Money: %d$" % moneyy
	displayed_moneyy = moneyy
	
func toggle_menu():
	Input.set_custom_mouse_cursor(null)
	if not $Menu.visible:
		get_tree().paused = true
		$Menu.show()
	else:
		close_menu()
	
func close_menu():
	Input.set_custom_mouse_cursor(current_cursor)
	get_tree().paused = false
	$Menu.hide()

func plant_blue_mode():
	current_mode = Mode.PLANT_BLUE_MODE
	Input.set_custom_mouse_cursor(graines_bleues)
	current_cursor = graines_bleues
	select_button(%PBButton)
	
func plant_red_mode():
	current_mode = Mode.PLANT_RED_MODE
	Input.set_custom_mouse_cursor(graines_rouges)
	current_cursor = graines_rouges
	select_button(%PRButton)
	
func cut_mode():
	current_mode = Mode.CUT_MODE
	Input.set_custom_mouse_cursor(secateur)
	current_cursor = secateur
	select_button(%CButton)
	
func grow_mode():
	current_mode = Mode.GROW_MODE
	Input.set_custom_mouse_cursor(arrosoir, 0, Vector2(0, 58))
	current_cursor = arrosoir
	select_button(%WCButton)
	
func select_button(button_pressed):
	button_pressed.texture_normal = cageot_select
	if selected_button and selected_button != button_pressed:
		selected_button.texture_normal = cageot
	selected_button = button_pressed
	
func _on_cop_timer_timeout() -> void:
	var look_ilegal = true
	var new_cop
	
	if randf() < RATIO_MEC:
		new_cop = mec_.instantiate()
	elif randf() < RATIO_MAF:
		new_cop = maf_.instantiate()
		look_ilegal = false
	else:
		new_cop = cop_.instantiate()
	
	var n = 0
	for p in $Plants.get_children():
		if (look_ilegal and not p.is_legal) or (not look_ilegal and p.is_legal):
			n += 1
			n *= 0.99
	
	n *= 0.6
	if not look_ilegal:
		n *= 0.5
	
	n = round(max(0.6 + total_cop / 3.0, n + total_cop / 3.0))
	n = min(n, round(2 + total_cop * 4))
	
	new_cop.position = $CopSpawn.position
	new_cop.to_be_seen = n
	new_cop.connect("bust", show_game_over)
	new_cop.connect("start_talking", talking)
	add_child(new_cop)
	$CopTimer.wait_time = max(1.5, WAIT_COP * 0.9 ** total_cop * (0.75 + randf() / 2.0))
	total_cop += 1
	$CopTimer.start()

func talking():
	await get_tree().create_timer(2.0).timeout
	$Player.start_talking()
	

func show_game_over() -> void:
	await get_tree().create_timer(3).timeout
	get_tree().paused = true
	Input.set_custom_mouse_cursor(null)
	$GameOverPanel.show()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.first_time = false
	get_tree().reload_current_scene()


func _on_credits_pressed() -> void:
	$CreditsPanel.show()
