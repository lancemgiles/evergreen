extends AudioStreamPlayer

var loop = true

func _on_finished() -> void:
	if loop:
		play()
	else:
		stop()
