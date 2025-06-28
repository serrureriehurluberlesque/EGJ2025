extends Area2D

signal cutted(value)

@export var is_legal := false
@export var value := 100.0
@export var full_growth := 100.0

var SPRITE_HEIGHT = 96.0
var LIMIT = 66.0
var GOTTAGOFAST = 10.0  # 1.0 for true game
var MAXCUTTAGE = 1.0

var growth := 0.0
var cuttage = 0.0
var leaves_to_emit = 0.0
var is_removing = false
var removing = 0.0
@onready var sprites = {$Step1: [0.0, 33.0], $Step2: [33.0, 66.0], $Step3: [66.0, 133.0], $Step4: [133.0, 170.0], $Step5: [170.0, 200.0]}


func _ready() -> void:
	for s in sprites:
		s.texture = s.texture.duplicate()
		if is_legal:
			s.modulate.r = 0.45
		else:
			s.modulate.g = 0.85
	update_sprites()


func _process(delta: float) -> void:
	grow(delta * GOTTAGOFAST)
	if leaves_to_emit >= 0.0:
		$Coupage.amount_ratio = 1.0
		leaves_to_emit -= delta
	else:
		$Coupage.amount_ratio = 0.0
	
	if is_removing:
		removing += delta * 3.0
		modulate.a = 1.0 - removing
		if removing >= 1.0:
			queue_free()


func grow(speed: float) -> void:
	var interest = is_interesting()
	
	growth = min(2 * full_growth, growth + speed)
	
	if interest != is_interesting():
		for c in get_overlapping_areas():
			c.regarde_attentivement(self)
	
	update_sprites()


func update_sprites():
	for s in sprites:
		var r = s.texture.region
		var h = min(SPRITE_HEIGHT, max(1, round(SPRITE_HEIGHT * growth / 100.0)))
		r.size = Vector2(r.size.x, h)
		s.texture.region = r
		s.position = Vector2(0, -h / 2)
	
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
	return growth >= LIMIT and growth < full_growth


func cut(delta):
	cuttage += delta
	leaves_to_emit += delta
	
	
	if cuttage >= MAXCUTTAGE:
		cutted.emit(get_value())
		is_removing = true


func get_value() -> float:
	if is_interesting():
		if is_legal:
			return growth / 10.0
		else:
			return growth
	else:
		return 0.0
