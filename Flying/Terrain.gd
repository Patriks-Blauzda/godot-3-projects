extends Spatial

export (NodePath) var mesh = null
export var n_seed = 0
export var n_octaves = 3
export var n_period = 64
export var n_persistence = 0.5
export var n_lacunarity = 2

export var draw_dist = 5000

func _create_noise():
	var noise = OpenSimplexNoise.new()
	noise.seed = n_seed
	noise.octaves = n_octaves
	noise.period = 64
	noise.lacunarity = n_lacunarity
	
	return noise


func _create_mesh(noise):
	pass


func _generate_terrain():
	var generated_noise = _create_noise()
	_create_mesh(generated_noise)
