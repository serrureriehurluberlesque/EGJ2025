extends Node2D

func _ready() -> void:
	$Plante.grow(33.0)
	$Plante2.grow(66.0)
	await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	print($Plante.get_cut())
	await get_tree().create_timer(1).timeout
