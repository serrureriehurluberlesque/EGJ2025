extends TextureRect

var t = 0

func _process(delta: float) -> void:
	t += delta

func _unhandled_input(event: InputEvent) -> void:
	if t > 0.5:
		if event.is_pressed():
			get_tree().change_scene_to_file("res://scenes/world/world.tscn")
 
