class_name Cop
extends Area2D

signal busted


func _process(delta: float) -> void:
	var p = get_position()
	p.x += delta * -10.0
	set_position(p)


func _on_area_entered(area: Area2D) -> void:
	if area.saw_illegal():
		busted.emit()
		print("Busted!")
