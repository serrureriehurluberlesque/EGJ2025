class_name Plant
extends Node2D

@export var is_legal := false
@export var value := 100.0
@export var max_growth := 100.0

var growth := 0.0

var SPRITE_HEIGHT = 128.0
@onready var sprites = [$Step1, $Step2, $Step3]


func _ready() -> void:
	for s in sprites:
		s.texture = s.texture.duplicate()
	update_sprites()

func _process(delta: float) -> void:
	grow(delta)


func grow(speed: float) -> void:
	growth = min(max_growth, growth + speed)
	update_sprites()


func update_sprites():
	for s in sprites:
		var r = s.texture.region
		r.size = Vector2(r.size.x, min(SPRITE_HEIGHT, max(1, round(SPRITE_HEIGHT * growth / 100.0))))
		print(r)
		s.texture.region = r


func saw_illegal() -> bool:
	return not is_legal and growth > 20.0


func get_cut() -> float:
	if not is_legal and growth == max_growth:
		return value
	else:
		return 0.0
