extends Spatial


onready var enemy_source = preload("res://Enemy.tscn")

var rng = RandomNumberGenerator.new()

var numbers = Vector3.ZERO

var active

func _ready():
	rng.randomize()
	$Timer.wait_time = rng.randi_range(6, 14)
	$Timer.start()

func _process(delta):
	if !Menu.spawns && active:
		active = false
		$Timer.stop()
	elif Menu.spawns && !active:
		active = true
		$Timer.start()

func randomize_location():
	rng.randomize()
	numbers += Vector3(rng.randf_range(-3, 3), 0, rng.randf_range(-3, 3))
	
	translation += numbers

func randomize_undo():
	translation -= numbers
	numbers = Vector3.ZERO

func spawn_enemy():
	randomize_location()
	
	var enemy_instance = enemy_source.instance()
	
	get_tree().root.get_child(1).get_node("Navigation/NavigationMeshInstance").add_child(enemy_instance)
	enemy_instance.transform.origin = self.global_transform.origin
	randomize_undo()

func _on_Timer_timeout():
	spawn_enemy()
