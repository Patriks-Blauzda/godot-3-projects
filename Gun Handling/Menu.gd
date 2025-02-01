extends Node

onready var sens = 0.04

var sussy = false

var death = false

var spawns = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Menu.hide()

func _process(delta):
	$FpsCount/Label.text = str(Engine.get_frames_per_second())
	
	$Menu/CenterContainer/VBoxContainer/Label.text = "Look sensitivity: " + str(sens)
	
	
	match spawns:
		true:
			$Menu/CenterContainer/VBoxContainer/EnemySpawn.text = "EnemySpawn: ON"
		false:
			$Menu/CenterContainer/VBoxContainer/EnemySpawn.text = "EnemySpawn: OFF"

func death():
	death = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Dead.show()

func _input(event):
	if event is InputEventKey && !death && !sussy:
		if event.scancode == KEY_ESCAPE:
			if event.is_pressed() && !event.echo:
			
				if get_tree().paused:
					get_tree().paused = false
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					$Menu.hide()
					get_tree().root.get_child(1).get_node("Player/Camera/TextureRect").show()
					
				else:
					get_tree().paused = true
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					$Menu.show()
					get_tree().root.get_child(1).get_node("Player/Camera/TextureRect").hide()


func _on_Resume_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Menu.hide()

func _on_Restart_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Menu.hide()
	$Dead.hide()
	death = false


func _on_Quit_pressed():
	get_tree().quit()


func _on_FpsToggle_pressed():
	$FpsCount.visible = not $FpsCount.visible


func _on_Sensitivity_value_changed(value):
	sens = $Menu/CenterContainer/VBoxContainer/Sensitivity.value


func _on_EnemySpawn_button_up():
	spawns = not spawns
