extends Particles

export var strength = 500

func _on_Area_body_entered(body):
	if body.name == "Player":
		body.in_updraft = true


func _on_Area_body_exited(body):
	if body.name == "Player":
		body.in_updraft = false
		body.vel.y += strength
