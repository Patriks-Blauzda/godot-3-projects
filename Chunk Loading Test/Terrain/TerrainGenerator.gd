extends StaticBody

var tmaterial = preload("res://Terrain/TerrainMaterial.tres")
const chunk_size = 32

var rng = RandomNumberGenerator.new()

var loaded_chunks = PoolVector2Array([])

var current_seed = generate_noise()

var draw_dist = 8

onready var player = get_owner().get_node("Player")

func generate_noise(oct = 2, period = 90.0, persist = 0.5, lacuna = 1.0):
	rng.randomize()
	
	var noise = OpenSimplexNoise.new()
	noise.seed = rng.randi()
	noise.octaves = oct
	noise.period = period
	noise.persistence = persist
	noise.lacunarity = lacuna
	
	return noise


func _load_terrain(pos : Vector2, noise : OpenSimplexNoise):
	var csh = CollisionShape.new()
	csh.name = str(pos)
	
	var vertices = PoolVector3Array([])
	
	csh.translation.x = pos.x * (chunk_size - 1)
	csh.translation.z = pos.y * (chunk_size - 1)
	
	csh.shape = HeightMapShape.new()
	csh.shape.map_width = chunk_size
	csh.shape.map_depth = chunk_size
	
	for y in chunk_size:
		for x in chunk_size:
			var point_data = noise.get_noise_2dv(Vector2(x, y) + (pos * chunk_size))
			
			var x_edge = (x == 0 || x == chunk_size - 1)
			var y_edge = (y == 0 || y == chunk_size - 1)
			
			if x_edge || y_edge:
				if x_edge && !y_edge:
					point_data += noise.get_noise_2dv(
						Vector2(x - int(x == 0) + int(x == chunk_size - 1), y) + (pos * chunk_size)
					)
				if y_edge && !x_edge:
					point_data += noise.get_noise_2dv(
						Vector2(x, y - int(y == 0) + int(y == chunk_size - 1)) + (pos * chunk_size)
					)
				
				if y_edge && x_edge:
					point_data += noise.get_noise_2dv(
						Vector2(
							x - int(x == 0) + int(x == chunk_size - 1), y - int(y == 0) + int(y == chunk_size - 1)
						) + (pos * chunk_size)
					)
				
				point_data /= 2
			
			
			csh.shape.map_data[x + (y * chunk_size)] = point_data * 20
			vertices.append(Vector3(x + 0.5, point_data * 20, y + 0.5))
	
	
	loaded_chunks.append(pos)
	call_deferred("add_child", csh)
	
	_create_mesh(csh, _rearrange_array(vertices))


func _rearrange_array(array : PoolVector3Array):
	var sorted_array = PoolVector3Array([])
	
	for y in range(1, chunk_size, 1):
		for x in range(0, chunk_size - 1, 1):
			# Triangle 1
			sorted_array.push_back(array[x + ((chunk_size * (y - 1)))])
			sorted_array.push_back(array[x + 1 + ((chunk_size * (y - 1)))])
			sorted_array.push_back(array[x + (chunk_size * y)])
			
			# Triangle 2
			sorted_array.push_back(array[x + 1 + ((chunk_size * (y - 1)))])
			sorted_array.push_back(array[x + 1 + (chunk_size * y)])
			sorted_array.push_back(array[x + (chunk_size * y)])
	
	
	return sorted_array


func _create_mesh(parent : Node, vert : PoolVector3Array):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in vert:
		st.add_vertex(x)
	var arraymesh = st.commit()
	arraymesh.surface_set_material(0, tmaterial)
	
	var meshinst = MeshInstance.new()
	meshinst.name = "MeshInstance"
	meshinst.mesh = arraymesh
	
	parent.call_deferred("add_child", meshinst)
	meshinst.translation = Vector3(chunk_size / -2.0, 0, chunk_size / -2.0)


func reload_chunks():
	for y in range(-draw_dist + 1, draw_dist + 1):
			for x in range(-draw_dist + 1, draw_dist + 1):
				if !loaded_chunks.has(Vector2(x, y) + player.current_chunk):
					_load_terrain(Vector2(x, y) + player.current_chunk, current_seed)


func _ready():
	reload_chunks()



func _process(_delta):
	var chunk_just_loaded = false
	
	for y in range(-draw_dist + 1, draw_dist + 1):
		for x in range(-draw_dist + 1, draw_dist + 1):
			if !loaded_chunks.has(Vector2(x, y) + player.current_chunk):
				_load_terrain(Vector2(x, y) + player.current_chunk, current_seed)
				chunk_just_loaded = true
				break
	
	
	for pos in loaded_chunks:
		if (pos.x > player.current_chunk.x + draw_dist || pos.x < player.current_chunk.x - draw_dist || 
			pos.y > player.current_chunk.y + draw_dist || pos.y < player.current_chunk.y - draw_dist):
				get_node(str(pos)).queue_free()
				loaded_chunks.remove(loaded_chunks.find(pos))
				break
