extends Label

func _init():
	Engine.set_max_fps(60)

func _process(delta: float) -> void:
	text = "FPS " + str(Engine.get_frames_per_second())



func _on_line_edit_text_submitted(new_text):
	Engine.set_max_fps(int(new_text))
	$LineEdit.release_focus()
