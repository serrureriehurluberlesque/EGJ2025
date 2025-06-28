extends Node2D

func _ready() -> void:
	$Plante.grow(33.0)
	$Plante2.grow(66.0)
	for i in 32:
		$Plante4.grow(1.0)
		await get_tree().create_timer(0.033).timeout
	await get_tree().create_timer(1).timeout
	for i in 31:
		$Plante3.cut(0.033)
		await get_tree().create_timer(0.033).timeout
	await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	for i in 31:
		$Plante5.cut(0.033)
		await get_tree().create_timer(0.033).timeout
