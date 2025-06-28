extends Node2D

signal closed

var explanation = "
Vous êtes un pauvre cultivateur de fleur, et deux choix s'offrent à vous: cultiver des fleurs basiques et rester dans la pauvreté, ou cultiver les [i]fleurs interdites de Ouïd[/i], plus risquées mais bien plus rentables.\n
Arriverez-vous à faire fortune en étant plus malin que les autorités ?\n
[u]Outils[/u]
[ul]
[b]Sac graines bleues[/b]: plante une graine de fleur normale
[b]Sac graines rouges[/b]: plante une graine de fleur Ouïd [i]interdite[/i]
[b]Cisailles[/b]: récolte une fleur si elle est à majorité; coupe la plante sans résultat sinon.
[b]Arrosoir[/b]: permet d'accélérer la pousse des fleurs.
[/ul]\n
[u]Prix[/u]
[center][table=3]
[cell][/cell][cell]Coût ($)[/cell][cell]Revenu ($)[/cell]
[cell]fleur bleue[/cell][cell]%d[/cell][cell]%d[/cell]
[cell]fleur rouge[/cell][cell]%d[/cell][cell]%d[/cell]
[/table][/center]
"

const COST_REVENUE_LIST = [1,1,1,2]

func _ready() -> void:
	$Background/Explanation.text = explanation % COST_REVENUE_LIST


func _on_close_button_pressed() -> void:
	closed.emit()
