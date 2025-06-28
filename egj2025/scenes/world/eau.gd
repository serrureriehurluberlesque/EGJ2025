extends GPUParticles2D

var arrose = 0.0

func _physics_process(delta: float) -> void:
	if arrose >= 0.0:
		amount_ratio = 1.0
		arrose -= delta
	else:
		amount_ratio = 0.0
	
