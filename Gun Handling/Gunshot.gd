extends Spatial

func _ready():
	$AudioStreamPlayer.play()

func _on_AudioStreamPlayer3D_finished():
	$AudioStreamPlayer.stop()
	queue_free()
