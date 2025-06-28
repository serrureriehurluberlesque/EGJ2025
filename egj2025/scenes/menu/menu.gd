extends Node2D

signal closed

var explanation = "
Vous êtes un pauvre cultivateur de fleur, et deux choix s'offrent à vous: cultiver des fleurs basiques et rester dans la pauvreté, ou cultiver les [i]fleurs interdites de Ouïd[/i], plus risquées mais bien plus rentables.\n
Arriverez-vous à faire fortune en étant plus malin que les autorités ?\n
[u]Outils[/u]
[ul]
[b]Sac graines bleues [lb]1[rb][/b]: plante une graine de fleur normale
[b]Sac graines rouges [lb]2[rb][/b]: plante une graine de fleur Ouïd [i]interdite[/i]
[b]Cisailles [lb]3[rb][/b]: récolte une fleur si elle est à majorité; coupe la plante sans résultat sinon.
[b]Arrosoir [lb]4[rb][/b]: permet d'accélérer la pousse des fleurs.
[/ul]\n
[u]Prix[/u]
[center][table=3]
[cell][/cell][cell]Coût ($)[/cell][cell]Revenu ($)[/cell]
[cell] [img]res://scenes/Bulle/assets/bleu.png[/img] [/cell][cell]%d[/cell][cell]%d[/cell]
[cell] [img]res://scenes/Bulle/assets/rouge.png[/img] [/cell][cell]%d[/cell][cell]%d[/cell]
[/table][/center]
"

const COST_REVENUE_LIST = [5, 0, 5, 25]

func _ready() -> void:
	$Background/Explanation.text = explanation % COST_REVENUE_LIST


func _on_close_button_pressed() -> void:
	closed.emit()
