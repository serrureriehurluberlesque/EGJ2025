extends Area2D

signal cutted(value)

@export var is_legal := false
@export var value := 100.0
@export var full_growth := 100.0

var SPRITE_HEIGHT = 96.0
var LIMITMIN = 66.0
var LIMITMAX = 133.0
var GOTTAGOFAST = 0.25  # 1.0 for true game
var MAXCUTTAGE = 1.0

var growth := 0.0
var cuttage = 0.0
var pognonage = 0.0
var leaves_to_emit = 0.0
var terre_to_emit = 0.1
var is_removing = false
var removing = 0.0
@onready var sprites = {$Step1: [0.0, 33.0], $Step2: [33.0, LIMITMIN], $Step3: [LIMITMIN, LIMITMAX], $Step4: [LIMITMAX, 150.0], $Step5: [150.0, 170.0], $Step6: [170.0, 200.0]}


func _ready() -> void:
	for s in sprites:
		s.texture = s.texture.duplicate()
		
		if is_legal:
			var r = s.texture.region
			r.position = Vector2(r.position.x + 64 * 3, r.position.y)
			s.texture.region = r
	
	if is_legal:
		$Interessant.modulate.r = 0.0
	else:
		$Interessant.modulate.b = 0.0
	update_sprites()


func _physics_process(delta: float) -> void:
	grow(delta * GOTTAGOFAST, false)
	if leaves_to_emit > 0.0:
		$Coupage.amount_ratio = 1.0
		leaves_to_emit -= delta
	else:
		$Coupage.amount_ratio = 0.0
	
	if terre_to_emit > 0.0:
		$Arrosage.amount_ratio = 1.0
		terre_to_emit -= delta
	else:
		$Arrosage.amount_ratio = 0.0
	
	if pognonage > 0.0:
		$Pognon.amount_ratio = 1.0
		pognonage -= delta
	else:
		$Pognon.amount_ratio = 0.0
	
	if is_removing:
		removing += delta * 1.5
		modulate.a = 1.0 - removing
		if removing >= 1.0:
			queue_free()
	
	if is_interesting():
		$Interessant.amount_ratio = 1.0
	else:
		$Interessant.amount_ratio = 0.0
		
	$ProgressBar.value = 1 - (growth - LIMITMIN) / (LIMITMAX - LIMITMIN)


func grow(speed: float, fast=true) -> void:
	if fast and growth < full_growth:
		terre_to_emit += speed
	
	var interest = is_interesting()
	
	growth = min(2 * full_growth, growth + speed * 15.0)
	
	if not interest and is_interesting():
		$ProgressBar.show()
		for c in get_overlapping_areas():
			c.regarde_attentivement(self)
	elif interest and not is_interesting():
		$ProgressBar.hide()
	
	update_sprites()


func update_sprites():
	for s in sprites:
		var r = s.texture.region
		var h = min(SPRITE_HEIGHT, max(1, round(SPRITE_HEIGHT * growth / 100.0)))
		r.size = Vector2(r.size.x, h)
		s.texture.region = r
		s.position = Vector2(0, -h / 2 + 8)
	
	for s in sprites:
		s.modulate.a = compute_growth_show(sprites[s])


func compute_growth_show(interval):
	if interval[0] < growth and growth < interval[1]:
		return 1.0
	else:
		if growth <= interval[0]:
			return min(1, max(0, 1 - (interval[0] - growth) / 10.0))
		else:
			return min(1, max(0, 1 - (growth - interval[1]) / 10.0))


func is_interesting():
	return growth >= LIMITMIN and growth < LIMITMAX


func cut(delta):
	cuttage += delta * 10.0
	leaves_to_emit += delta * 3.0
	
	
	if cuttage >= MAXCUTTAGE:
		cutted.emit(get_value())
		pognonage += get_value() / 50.0
		var d = Vector2(566, 0) - get_position()
		var v = d.length() * 1.5
		d = d.normalized()
		$Pognon.process_material.direction = Vector3(d.x, d.y, 0)
		$Pognon.process_material.initial_velocity_min = v
		$Pognon.process_material.initial_velocity_max = v

		is_removing = true


func get_value() -> float:
	if is_interesting():
		if is_legal:
			return 0  # growth / 3.5
		else:
			return growth / 2.0
	else:
		return 0.0


func start_highlight():
	modulate = Color(1.2, 1.2, 1.2, modulate.a)


func stop_highlight():
	modulate = Color(1.0, 1.0, 1.0, modulate.a)
