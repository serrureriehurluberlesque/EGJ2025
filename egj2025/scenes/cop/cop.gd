class_name Cop
extends Area2D

signal bust
signal start_talking

@export var to_be_seen := 3
@export var is_maf := false

var seen_one = false
var busted = false
var v = 1.0
var walking = true
var leaving = false
var left = 0.0
var inited = false
var talking = false
var regarded = []
var current_waypoint = Vector2(0, 0)
var previous_waypoint = Vector2(0, 0)

var ENTRY = Vector2(992.0, 480.0)
var DELTAX = 384.0
var DELTAY = 256.0
var SPEED = 25.0

var waypoints = {
	Vector2(0, 0): Vector2(),
	Vector2(-1, 0): Vector2(),
	Vector2(-2, 0): Vector2(),
	Vector2(0, 1): Vector2(),
	Vector2(-1, 1): Vector2(),
	Vector2(-2, 1): Vector2(),
	Vector2(0, -1): Vector2(),
	Vector2(-1, -1): Vector2(),
	Vector2(-2, -1): Vector2(),
}


func _ready():
	connect("bust", buste)
	update_bulle()
	compute_waypoints()


func compute_waypoints():
	for w in waypoints:
		waypoints[w] = ENTRY + Vector2(w.x* DELTAX, w.y* DELTAY)


func walk(delta):
	if (get_position() - waypoints[current_waypoint]).length() < 5.0:
		compute_next_waypoint()
	else:
		var dp = (waypoints[current_waypoint] - get_position())
		var l = min(SPEED * delta * 1.0 if inited else 3.0, dp.length())
		
		set_position(get_position() + dp.normalized() * l)
		self.z_index = get_position()[1] / 64	


func egalish(v1, v2):
	return (v1 - v2).length() < 0.01


func is_ok_waypoint(next_waypoint):
	var is_in_waypoints = false
	for w in waypoints:
		if egalish(w, next_waypoint):
			is_in_waypoints = true
	return is_in_waypoints and not egalish(current_waypoint, next_waypoint) and not egalish(previous_waypoint, next_waypoint)


func get_nearest_waypoint(next_waypoint):
	for w in waypoints:
		if egalish(w, next_waypoint):
			return w


func compute_next_waypoint():
	if inited:
		var next_waypoint = Vector2(-99, -99)
		while not is_ok_waypoint(next_waypoint):
			next_waypoint = current_waypoint + Vector2(1.0, 0).rotated(PI/2 * (randi() % 4))
		previous_waypoint = current_waypoint
		current_waypoint = get_nearest_waypoint(next_waypoint)
	elif not talking:
		start_talking.emit()
		$Bulle.update_text(" On m'a dit qu'il y a %d %s ici!! " % [to_be_seen, "[img]res://scenes/Bulle/assets/bleu.png[/img]" if is_maf else "[img]res://scenes/Bulle/assets/rouge.png[/img]"])
		talking = true
		await get_tree().create_timer(8).timeout
		inited = true
		update_bulle()
		for c in get_overlapping_areas():
			regarde(c)


func _physics_process(delta: float) -> void:
	if walking:
		walk(delta)
	if leaving:
		left += delta
		modulate.a = 1.0 - left
		if left >= 1.0:
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	regarde(area)


func regarde(area):
	if area.is_interesting():
		regarde_attentivement(area)


func check_legal(is_legal):
	return (is_legal and not is_maf) or (not is_legal and is_maf)


func regarde_attentivement(area):
	if inited:
		if not area in regarded:
			var ok = is_ok()
			if check_legal(area.is_legal):
				to_be_seen -= 1
				seen_one = true
				regarded.append(area)
			else:
				bust.emit()
			
			if ok != is_ok():
				walking = false
				leaving = true
			update_bulle()


func buste():
	busted = true
	walking = false


func is_ok():
	return to_be_seen <= 0


func update_bulle():
	if inited:
		if (busted and not is_maf):
			$Bulle.update_text(" Mais c'est de la Ouïd, chenapan ! ")
		elif busted:
			$Bulle.update_text("Mais c'est de la Nônd, collabo !")
		elif is_ok():
			$Bulle.update_text(" Ok, ça semble en ordre... ")
		else:
			$Bulle.update_text("  Je veux voir %s%d %s !  " % ["encore " if seen_one else "", to_be_seen, "[img]res://scenes/Bulle/assets/rouge.png[/img]" if is_maf else "[img]res://scenes/Bulle/assets/bleu.png[/img]"])
