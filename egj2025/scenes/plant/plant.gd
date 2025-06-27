class_name Plant
extends Node2D

@export var is_legal := false
@export var value := 100.0
@export var max_growth := 100.0

var growth := 0.0


func _process(delta: float) -> void:
	grow(delta)


func grow(speed: float) -> void:
	growth = min(max_growth, growth + speed)
	$Top.position = Vector2(0, -growth)


func saw_illegal() -> bool:
	return not is_legal and growth > 20.0


func get_cut() -> float:
	if not is_legal and growth == max_growth:
		return value
	else:
		return 0.0
