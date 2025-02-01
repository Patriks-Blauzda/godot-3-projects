extends KinematicBody

var sens = 0.1

var jumpstrength = 50
var movespd = 50
var accel = 4

var y_vel = 0
var gravity = 1


var vel = Vector3.ZERO
var current_chunk = Vector2.ZERO


func _ready():
	pass
	OS.center_window()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		# Moves camera, speed dependant on sensitivity (crazy revalation)
		# Camera is a child of the CameraAnchor node for 3rd person cam purposes
		# (Camera rotates relative to the anchor node, located on the player)
		$CameraAnchor.rotation_degrees.x -= event.relative.y * sens
		$CameraAnchor.rotation_degrees.y -= event.relative.x * sens
		
		# Stops the camera from going too far up/down
		$CameraAnchor.rotation_degrees.x = clamp($CameraAnchor.rotation_degrees.x, -65, 65)
	
	
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
	
	# Takes the X (sideways) and Z (forward/backward) axis of the camera's relative angles (basis)
	if Input.is_action_pressed("up"):
		move_dir -= $CameraAnchor.transform.basis.z
		
	if Input.is_action_pressed("down"):
		move_dir += $CameraAnchor.transform.basis.z
		
	if Input.is_action_pressed("left"):
		move_dir -= $CameraAnchor.transform.basis.x
		
	if Input.is_action_pressed("right"):
		move_dir += $CameraAnchor.transform.basis.x
	
	# Remove the Y axis and normalize so speed stays consistent regardless of camera angle
	move_dir = Vector2(move_dir.x, move_dir.z).normalized()
	
	# Makes number go up but gradually
	# Acceleration multiplied by 0.25 if in the air, 1.25 if on the ground
	# Also counts for deacceleration
	vel = vel.linear_interpolate(
		Vector3(move_dir.x, 0, move_dir.y) * movespd,
		accel * (0.25 + int(is_on_floor())) * deltavalue
	)
	



func _vertical_motion():
	if is_on_floor():
		y_vel = -0.01
	elif y_vel < 1000:
		y_vel = clamp(y_vel - gravity / 1.5, -1000, 1000)
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		y_vel = jumpstrength
	
	vel.y = y_vel


func _physics_process(delta):
	_player_movement(delta)
	_vertical_motion()
	
	
	var _collision = move_and_slide_with_snap(vel, Vector3.DOWN, Vector3.UP)
	
	current_chunk = Vector2(floor((translation.x - 16) / 32), floor((translation.z - 16) / 32))
	$Label.text = "chunk coords {0}\nFPS: ({1})".format([current_chunk, Performance.get_monitor(Performance.TIME_FPS)])



