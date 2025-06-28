extends Node2D

signal closed

var explanation = "
Vous êtes un pauvre cultivateur de fleur, et votre unique option pour gagner de l'argent est de cultiver les [i]fleurs interdites de Ouïd[/i].\n
Les contrôles de polices sont fréquents. Pour faire diversion, il pourrait être utile de tout de même cultiver des fleurs normales.\n
[u]Outils[/u]
[ul]
[b]Sac graines bleues [lb]1[rb][/b]: Plante une graine de fleur normale
[b]Sac graines rouges [lb]2[rb][/b]: Plante une graine de fleur Ouïd [i]interdite[/i]
[b]Cisailles [lb]3[rb][/b]: Coupe les plantes pour libérer la place. Si la plante est en fleur, récolte également son revenu.
[b]Arrosoir [lb]4[rb][/b]: Permet d'accélérer la pousse des fleurs.
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
