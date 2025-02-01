extends KinematicBody

export var sens = 0.15

export var movespd = 100
export var accel = 10
export var jumpstrength = 150
export var gravity = 4.5

export var flying_turnspeed = 6
export var flight_speed_cap = 3

var vel = Vector3.ZERO
var y_vel = 0

var in_updraft = false

var updir = Vector3.UP

var state = "normal"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	OS.center_window()


func _input(event):
	if event is InputEventMouseMotion:
		$CameraAnchor.rotation_degrees.x -= event.relative.y * sens
		$CameraAnchor.rotation_degrees.y -= event.relative.x * sens
		
		$CameraAnchor.rotation_degrees.x = clamp($CameraAnchor.rotation_degrees.x, -89, 89)
	
	
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		
		if event.scancode == KEY_Q && event.pressed:
			match Input.mouse_mode:
				2:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				0:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if event.scancode == KEY_R && event.pressed:
			var _reload = get_tree().reload_current_scene()


func _player_movement(deltavalue):
	var move_dir = Vector3.ZERO
	
	if Input.is_action_pressed("up"):
		move_dir -= $CameraAnchor.transform.basis.z
		
	if Input.is_action_pressed("down"):
		move_dir += $CameraAnchor.transform.basis.z
		
	if Input.is_action_pressed("left"):
		move_dir -= $CameraAnchor.transform.basis.x
		
	if Input.is_action_pressed("right"):
		move_dir += $CameraAnchor.transform.basis.x
	
	move_dir = Vector2(move_dir.x, move_dir.z).normalized()
	
	vel = vel.linear_interpolate(
		Vector3(move_dir.x, 0, move_dir.y) * movespd,
		accel * (0.25 + int(is_on_floor())) * deltavalue
	)
	
	$MeshInstance.rotation_degrees = Vector3.ZERO
	$MeshInstance.rotation_degrees.y = $CameraAnchor.rotation_degrees.y


func _vertical_motion():
	# y_vel is used to preserve vertical velocity, so you can fall at higher speeds
	
	if is_on_floor():
		y_vel = -0.01
	elif y_vel < 1000:
		y_vel = clamp(y_vel - gravity / 1.5, -1000, 1000)
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		y_vel = jumpstrength
	
	vel.y = y_vel


var speed_mult = 1

var flight_dir = Vector3.ZERO

func _flying(deltavalue):
	# Saved forward direction relative to camera, gradually gets to it (speed dependant too)
	flight_dir = flight_dir.linear_interpolate(
		-$CameraAnchor.transform.basis.z, flying_turnspeed / speed_mult * deltavalue
	)
	
	flight_dir = Vector3(flight_dir.x, 0, flight_dir.z).normalized()
	
	# Gets the camera's vertical angle
	var y_angle = -$CameraAnchor.transform.basis.z.y
	
	# Changes speed based on the camera's vertical angle
	# Capped at 4x speed
	if y_angle > 0.15:
		speed_mult = clamp(speed_mult - y_angle / 50, 0.1, flight_speed_cap)
		
		vel.y += (abs(vel.x) + abs(vel.z)) * y_angle * 0.025
		
	elif y_angle < -0.15:
		speed_mult = clamp(speed_mult - y_angle / 35, 0.1, flight_speed_cap)
		
		vel.y += (abs(vel.x) + abs(vel.z)) * y_angle * 0.1
	
	# Turning velocity increased gradually by turn speed
	if vel.y < 250:
		vel = vel.linear_interpolate(flight_dir * movespd * speed_mult, flying_turnspeed * deltavalue)
	else:
		vel.y *= 0.95
	
	# Vertical velocity controlled by speed multiplier and vertical camera angle
	if !in_updraft:
		vel.y -= gravity / 2 * speed_mult * -y_angle
		if speed_mult < 0.3:
			vel.y -= gravity + (speed_mult * y_angle)
		
		y_vel = vel.y
	
	else:
		vel.y += gravity * 5
		vel.x *= 0.98
		vel.z *= 0.98
	
	if is_on_wall():
		vel = get_slide_collision(0).normal * 100 * speed_mult
	
	# Turns the playermodel to where the camera is facing
	$MeshInstance.rotation_degrees = $MeshInstance.rotation_degrees.linear_interpolate(
		$CameraAnchor.rotation_degrees, flying_turnspeed / speed_mult * deltavalue
	)
	$MeshInstance.rotation_degrees.z = $CameraAnchor.rotation_degrees.y - $MeshInstance.rotation_degrees.y


func _physics_process(delta):
	match state:
		"normal":
			
			_player_movement(delta)
			_vertical_motion()
			
			$MeshInstance/Wings.hide()
			
			if Input.is_action_just_pressed("jump") && !is_on_floor():
				flight_dir = Vector3.ZERO
				speed_mult = 1
				vel.y = y_vel
				
				state = "flying"
		
		"flying":
			_flying(delta)
			
			$MeshInstance/Wings.show()
			
			if is_on_floor() || Input.is_action_just_pressed("jump"):
				state = "normal"
	
	# Speedometer number and bar control
	$CameraAnchor/Camera/ProgressBar/Label.text = str(floor((vel + translation).distance_to(translation)))
	$CameraAnchor/Camera/ProgressBar.value = floor((vel + translation).distance_to(translation))
	
	vel = move_and_slide(vel, updir)
	
	
	if translation.y < -5000:
		translation.y = 5000
