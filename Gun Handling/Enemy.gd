extends KinematicBody

onready var player = get_tree().root.get_child(1).get_node("Player")
onready var nav = get_tree().root.get_child(1).get_node("Navigation")

var active = false
var falling = true
var dead = false

var path : PoolVector3Array = []
var show_path = true

export var walkspd = 3.5
export var dmg = 15
export var maxhp = 75
var hp = maxhp

var vel = Vector3()
var y_axis_vel = 0

func y_axis(jumpheight : int = 4):
	if is_on_floor():
		y_axis_vel = 0
	else:
		y_axis_vel -= 0.8
	return y_axis_vel


func _process(delta):
	if hp < 1 && !dead:
		dead = true
		active = false
		$Area/CollisionShape.disabled = true
		if player.hp < player.maxhp:
			player.hp += 2
		
		$AnimationPlayer.play("Death")

func _physics_process(delta):
	if falling && is_on_floor():
		falling = false
		active = true
	
	if active:
		if transform.origin.distance_to(player.transform.origin) < 2.5:
			$AnimationPlayer.play("Attack")
			active = false
		
		if path.size() > 0:
			move_to_target()
		
	else:
		vel.x = 0
		vel.z = 0
	
	var collision = move_and_slide(Vector3(vel.x, vel.y + y_axis(), vel.z), Vector3.UP)

func move_to_target():
	if global_transform.origin.distance_to(path[0]) < 2:
		path.remove(0)
	else:
		var direction = path[0] - global_transform.origin
		vel = direction.normalized() * walkspd


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Death":
			queue_free()
		"Attack":
			$Timer.start()
			


func _on_Timer_timeout():
	active = true


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		if body.get_node("Timer").is_stopped():
			body.hp -= dmg
			body.get_node("Timer").start()
			
			body.y_axis_vel = 10
			body.vel = body.global_transform.origin.direction_to(transform.origin)*-10


func _on_Pathfinding_timeout():
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
