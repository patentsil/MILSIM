extends Control

signal ChatOpened
signal ChatClosed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_action_bar_chat_opened():
	visible = true


func _on_action_bar_chat_closed():
	visible = false