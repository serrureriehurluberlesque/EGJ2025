extends Area2D

@export var is_legal := false
@export var value := 100.0
@export var max_growth := 100.0

var growth := 0.0

var SPRITE_HEIGHT = 128.0
var GOTTAGOFAST = 10.0  # 1.0 for true game
@onready var sprites = {$Step1: [0.0, 33.0], $Step2: [33.0, 66.0], $Step3: [66.0, 100.0]}


func _ready() -> void:
	for s in sprites:
		s.texture = s.texture.duplicate()
	update_sprites()

func _process(delta: float) -> void:
	grow(delta * GOTTAGOFAST)


func grow(speed: float) -> void:
	growth = min(max_growth, growth + speed)
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

func saw_illegal() -> bool:
	return not is_legal and growth > 20.0


func get_cut() -> float:
	if not is_legal and growth == max_growth:
		return value
	else:
		return 0.0
