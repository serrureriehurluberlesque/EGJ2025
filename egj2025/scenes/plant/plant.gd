class_name Plant
extends Node2D

@export var max_growth := 100.0

var growth := 0.0


func _process(delta: float) -> void:
	grow(delta)


func grow(speed: float) -> void:
	growth = min(max_growth, growth + speed)
	$Top.position = Vector2(0, -growth)
