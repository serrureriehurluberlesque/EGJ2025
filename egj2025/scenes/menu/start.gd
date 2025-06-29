extends TextureRect

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
