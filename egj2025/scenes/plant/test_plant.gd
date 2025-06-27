extends Node2D

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	$Plant.grow(30.0)
	await get_tree().create_timer(1).timeout
	print($Plant.saw_illegal())
	await get_tree().create_timer(1).timeout
	print($Plant.get_cut())
	await get_tree().create_timer(1).timeout
