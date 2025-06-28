class_name Plant
extends Node2D
	

func start_talking(n):
	$Bulle.update_text("🌿? ❌🌿!")
	await get_tree().create_timer(2).timeout

	$Bulle.update_text("Bla bla malentendu!")
	await get_tree().create_timer(2).timeout
	$Bulle.update_text("🏵️!")
