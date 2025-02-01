extends GridMap

var cleared = false

var limits = [Vector2(9, -4), Vector2(14, 1)]

func flip(pos : Vector3):
	var coords = world_to_map(pos)
	var cell_item = get_cell_item(coords.x, coords.y, coords.z)
	
	set_cell_item(coords.x, coords.y, coords.z, not cell_item, 22)
	
	var offset = 1
	
	while (get_cell_item(coords.x, coords.y + offset, coords.z) != -1 or 
	get_cell_item(coords.x, coords.y - offset, coords.z) != -1):
		
		if coords.y + offset >= limits[0].x && coords.y + offset <= limits[1].x:
			set_cell_item(coords.x, coords.y + offset, coords.z,
			not get_cell_item(coords.x, coords.y + offset, coords.z), 22)
		if coords.y - offset >= limits[0].x && coords.y - offset <= limits[1].x:
			set_cell_item(coords.x, coords.y - offset, coords.z,
			not get_cell_item(coords.x, coords.y - offset, coords.z), 22)
		
		offset += 1
	
	offset = 1
	
	while (get_cell_item(coords.x, coords.y, coords.z + offset) != -1 or 
	get_cell_item(coords.x, coords.y, coords.z - offset) != -1):
		if coords.z + offset >= limits[0].y && coords.z + offset <= limits[1].y:
			set_cell_item(coords.x, coords.y, coords.z + offset,
			not get_cell_item(coords.x, coords.y, coords.z + offset), 22)
			
		if coords.z - offset >= limits[0].y && coords.z - offset <= limits[1]. y:
			set_cell_item(coords.x, coords.y, coords.z - offset, 
			not get_cell_item(coords.x, coords.y, coords.z - offset), 22)
			
		offset += 1
	
	cleared = true
	for y in range(limits[0].x, limits[1].x):
		for x in range(limits[0].y, limits[1].y):
			if !get_cell_item(9, y, x):
				cleared = false
				break
		if !cleared:
			break
	
	if cleared:
		$Particles.emitting = true
		$Particles2.emitting = true
		$Particles3.emitting = true
		cleared = false
