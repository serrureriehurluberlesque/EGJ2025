class_name Cop
extends Area2D

signal bust

@export var to_be_seen := 3

var busted = false
var v = 1.0

func _ready():
	connect("bust", buste)
	update_bulle()


func _process(delta: float) -> void:
	var p = get_position()
	p.x += delta * -25.0 * v
	set_position(p)


func _on_area_entered(area: Area2D) -> void:
	regarde(area)


func regarde(area):
	if area.is_interesting():
		regarde_attentivement(area)


func regarde_attentivement(area):
		var ok = is_ok()
		if area.is_legal:
			to_be_seen -= 1
		else:
			bust.emit()
		
		if ok != is_ok():
			v *= -1.0
		update_bulle()


func buste():
	busted = true
	v = 0.0


func is_ok():
	return to_be_seen <= 0

func update_bulle():
	if busted:
		$Bulle.update_text("Il n'y avait pas de malentendu, chenapan!")
	elif is_ok():
		$Bulle.update_text("Is ok!")
	else:
		$Bulle.update_text("%d🌿?!" % [to_be_seen])
