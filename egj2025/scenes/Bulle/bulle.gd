extends Node2D


func _ready() -> void:
	update_text("")
	hide()


func update_text(t):
	if t:
		show()
		$Label.text = t
	else:
		hide()
