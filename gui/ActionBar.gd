extends Node2D
signal ChatOpened
signal ChatClosed
signal AmountOfMessagesChanged(amount)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_chat_closed():
	pass # Replace with function body.

func _on_chat_opened():
	pass # Replace with function body.


func _on_chat_drop_toggled(button_pressed):
	if button_pressed:
		ChatOpened.emit()
	else:
		ChatClosed.emit()


func _on_amount_of_messages_changed(amount):
	$ChatDrop/lblAmountOfMessages.text = str(amount)
