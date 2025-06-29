class_name Plant
extends Node2D
	

func start_talking():
	$Bulle.update_text(" Des %s ici ??? " % ["[img]res://scenes/Bulle/assets/rouge.png[/img] "])
	await get_tree().create_timer(2).timeout
	$Bulle.update_text(" C'est un malentendu ! ")
	await get_tree().create_timer(2).timeout
	$Bulle.update_text(" Il ne pousse que des %s ici ! " % ["[img]res://scenes/Bulle/assets/bleu.png[/img] "])
	await get_tree().create_timer(2).timeout
	$Bulle.update_text("")
