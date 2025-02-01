extends Panel

var selected = null
var index = 0

func _on_Button_button_up():
	get_tree().paused = false
	hide()
	Menu.sussy = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	if selected != null && !selected.get_child(0).disabled:
		selected.points[index] = get_local_mouse_position()
		if !selected.get_child(0).pressed:
			match index:
				0:
					selected.points[0] = Vector2(9, 45)
				1:
					selected.points[1] = Vector2(71, 45)
			selected = null


func _on_A1_button_down():
	selected = $A1
	index = 1


func _on_A2_button_down():
	selected = $A2
	index = 1


func _on_A3_button_down():
	selected = $A3
	index = 1


func _on_A4_button_down():
	selected = $A4
	index = 1


func _on_A5_button_down():
	selected = $A5
	index = 0


func _on_A6_button_down():
	selected = $A6
	index = 0


func _on_A7_button_down():
	selected = $A7
	index = 0


func _on_A8_button_down():
	selected = $A8
	index = 0


func _on_A1_mouse_entered():
	if selected == $A5 && !selected.get_child(0).pressed:
		selected.points[0] = Vector2(-359, -73)
		$A1/A1.disabled = true
		$A5/A5.disabled = true


func _on_A2_mouse_entered():
	if selected == $A6 && !selected.get_child(0).pressed:
		selected.points[0] = Vector2(-370, 105)
		$A2/A2.disabled = true
		$A6/A6.disabled = true


func _on_A3_mouse_entered():
	if selected == $A7 && !selected.get_child(0).pressed:
		selected.points[0] = Vector2(-367, 15)
		$A3/A3.disabled = true
		$A7/A7.disabled = true


func _on_A4_mouse_entered():
	if selected == $A8 && !selected.get_child(0).pressed:
		selected.points[0] = Vector2(-366, 168)
		$A4/A4.disabled = true
		$A8/A8.disabled = true


func _on_A5_mouse_entered():
	if selected == $A1 && !selected.get_child(0).pressed:
		selected.points[1] = Vector2(437, 161)
		$A5/A5.disabled = true
		$A1/A1.disabled = true


func _on_A6_mouse_entered():
	if selected == $A2 && !selected.get_child(0).pressed:
		selected.points[1] = Vector2(447, -14)
		$A6/A6.disabled = true
		$A2/A2.disabled = true


func _on_A7_mouse_entered():
	if selected == $A3 && !selected.get_child(0).pressed:
		selected.points[1] = Vector2(447, 76)
		$A7/A7.disabled = true
		$A3/A3.disabled = true


func _on_A8_mouse_entered():
	if selected == $A2 && !selected.get_child(0).pressed:
		selected.points[1] = Vector2(448, -78)
		$A8/A8.disabled = true
		$A4/A4.disabled = true
