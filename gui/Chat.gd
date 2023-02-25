extends Control

signal ChatOpened
signal ChatClosed
var unreadCount = 0

func getCurrentCharacter():
	return getCurrentPlayer().character

func getCurrentPlayer():
	var world = get_tree().root.get_node("World")
	for node in world.get_node("Players").get_children():
		var player := node as Player
		if not player:
			continue
		if node.PeerId == multiplayer.get_unique_id():
			return node
		elif not multiplayer.is_server():
			print("Player " + player.Name + " had " + str(player.PeerId))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func append_text(text):
	$TextEdit.text += text + "\n"

@rpc("any_peer")
func transfer_message_to_server(message):
	append_text(message)
	receiveMessage.rpc(message)
	
@rpc("any_peer")
func receiveMessage(message):
	if not visible:
		unreadCount += 1
	get_tree().root.get_node("World/ActionBar").emit_signal("AmountOfMessagesChanged", unreadCount)
	append_text(message)

func send_global_message(message) -> void:
	if multiplayer.is_server():
		append_text(message)
		receiveMessage.rpc(message)
	else:
		transfer_message_to_server.rpc(message)

func _on_action_bar_chat_opened():
	visibleStateChanged(true)


func _on_action_bar_chat_closed():
	visibleStateChanged(false)

func visibleStateChanged(isVisible):
	visible = isVisible
	var char = getCurrentCharacter()
	char.set_process(not isVisible)
	char.set_process_input(not isVisible)
	char.set_process_unhandled_key_input(not isVisible)

func _on_text_edit_2_text_submitted(new_text):
	if new_text.strip_edges() == "":
		return
	send_global_message(getCurrentPlayer().Name + ": " + new_text)
	$TextEdit2.text = ""
	
func _input(event):
	if event.is_action_pressed("toggle_chat"):
		visible = not visible
		if visible:
			await get_tree().create_timer(0.05).timeout
			$TextEdit2.grab_focus()
			unreadCount = 0
			get_tree().root.get_node("World/ActionBar").emit_signal("AmountOfMessagesChanged", 0)
			visibleStateChanged(true)
			return

func _unhandled_input(event):
	if visible and $TextEdit2.has_focus():
		print("Accepted input event")
		$TextEdit2.accept_event()

func _unhandled_key_input(event):
	if visible and $TextEdit2.has_focus():
		print("Accepted input event")
		$TextEdit2.accept_event()

