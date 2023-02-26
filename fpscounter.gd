extends Label

func _init():
	Engine.set_max_fps(60)

func _process(delta: float) -> void:
	text = "FPS " + str(Engine.get_frames_per_second())



func _on_line_edit_text_submitted(new_text):
	Engine.set_max_fps(int(new_text))


func _on_focus_entered():
	$LineEdit.show()
	$LineEdit.grab_focus()


func _on_focus_exited():
	$LineEdit.hide()
	$LineEdit.release_focus()
