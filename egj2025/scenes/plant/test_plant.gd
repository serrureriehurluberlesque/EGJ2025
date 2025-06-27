extends Node2D

func _ready() -> void:
	$Plant.grow(33.0)
	$Plant2.grow(66.0)
	await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	print($Plant.saw_illegal())
	await get_tree().create_timer(1).timeout
	print($Plant.get_cut())
	await get_tree().create_timer(1).timeout
