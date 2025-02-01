extends KinematicBody

# Pistol 3D model source: https://opengameart.org/content/cc0-flat-guns-west

onready var gunsound = load("res://Gunshot.tscn")

export var gunshot = false

export var walkspd = 3
export var maxhp = 125
var hp = 100
export var runspd = 1.8
export var jumpheight = 0.5
export var dmg = 25

var maxammo = 7
var ammo = 7

var decal = preload("res://BulletHole.tscn")

var vel = Vector3()
var y_axis_vel = 0

var mouse_pos = Vector2(0, 0)

func _input(event):
	if event is InputEventMouseMotion:
		if !event.is_action_pressed("Use Slide"):
			$Camera.rotation_degrees.x -= event.relative.y * Menu.sens
			$Camera.rotation_degrees.y -= event.relative.x * Menu.sens
			
			$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -89, 89)


func move_player():
	vel.x = 0
	vel.z = 0
	
	if Input.is_key_pressed(KEY_W):
		vel += -$Camera.transform.basis.z
	elif Input.is_key_pressed(KEY_S):
		vel += $Camera.transform.basis.z
	
	if Input.is_key_pressed(KEY_A):
		vel += -$Camera.transform.basis.x
	elif Input.is_key_pressed(KEY_D):
		vel += $Camera.transform.basis.x
	
	vel = vel.normalized()
	vel = Vector3(vel.x * walkspd, 0, vel.z * walkspd)
	
	if Input.is_key_pressed(KEY_SHIFT):
		vel *= runspd

func y_axis(jumpheight : int):
	if is_on_floor() && $Timer.is_stopped():
		if Input.is_key_pressed(KEY_SPACE):
			y_axis_vel = 15
		else:
			y_axis_vel = 0
	else:
		y_axis_vel -= 0.8
	
	return y_axis_vel

func _process(delta):
	$HP/Label.text = str(hp)
	
	if hp < 1:
		Menu.death()
	
	if gunshot:
		$Camera/Pistol.add_child(gunsound.instance())
		gunshot = false



func _physics_process(delta):
	if hp > maxhp:
		hp = maxhp
	
	$Panel/Label.text = str(ammo) + "/" + str(maxammo)
	
	if $Timer.is_stopped():
		move_player()
	
	
	var collision = move_and_slide(Vector3(vel.x, y_axis(jumpheight), 
	vel.z), Vector3.UP)
	
	if Input.is_mouse_button_pressed(1) && !$Camera/Pistol/AnimationPlayer.is_playing() && ammo > 0:
		$Camera/Pistol/AnimationPlayer.play("Shoot")
	
	var raycast = $Camera/Pistol/RayCast
	if raycast.enabled:
		raycast.force_raycast_update()
		var bhole = decal.instance()
		
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("Enemies"):
				raycast.get_collider().hp -= dmg
				raycast.get_collider().get_node("Spatial").add_child(bhole)
			
			elif raycast.get_collider().is_in_group("Puzzle"):
				raycast.get_collider().flip(raycast.get_collision_point())
			
			else:
				raycast.get_collider().add_child(bhole)
				
			bhole.global_transform.origin = raycast.get_collision_point()
			bhole.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
			bhole.get_node("Particles").emitting = true
			
			raycast.enabled = false
			
		else:
			raycast.enabled = false
	
	
	if Input.is_key_pressed(KEY_R) && ammo != maxammo && !$Camera/Pistol/AnimationPlayer.is_playing():
		$Camera/Pistol/AnimationPlayer.play("Eject")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Shoot":
			ammo -= 1
		"Eject":
			ammo = maxammo
