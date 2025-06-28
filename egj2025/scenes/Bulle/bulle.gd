extends Node2D


func _ready() -> void:
	update_text("")
	hide()
	

func update_text(t):
	show()
	$Label.text = t
