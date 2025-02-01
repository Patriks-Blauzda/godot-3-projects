extends MeshInstance


func _physics_process(delta):
	look_at(get_tree().root.get_child(1).get_node("Player").transform.origin, Vector3.UP)
	rotation_degrees.x -= 90
	rotation_degrees.z += 180
