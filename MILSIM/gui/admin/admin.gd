extends Control

signal ChatOpened
signal ChatClosed
var unreadCount = 0

func getCurrentCharacter():
	for child in get_tree().root.get_node("World").get_children():
		if child is Character and child.peer_id == multiplayer.get_unique_id():
			return child

func getCurrentPlayer():
	var world = get_tree().root.get_node("World")
	for node in world.get_node("Players").get_children():
		var player := node as Player
		if not player:
			continue
		if node.PeerId == multiplayer.get_unique_id():
			return node
		elif not multiplayer.is_server():
			pass
			#print("Player " + player.Name + " had " + str(player.PeerId))

func append_text(text):
	$TextEdit.text += text + "\n"

var commands = {
	"bring":
		func(calling_player, players, arguments):
			var calling_char = Utils.getCharacterFromPlayer(calling_player)
			for player in players:
				var char = Utils.getCharacterFromPlayer(player)
				char.global_transform = calling_char.global_transform
}

func get_command(command_name):
	return commands[command_name]

func process_command(sending_player, command_text):
	var split = command_text.rsplit(" ")
	var command_name = split[0]
	var command_func = get_command(command_name)
	if not command_func:
		print("Now going to send rpc_id to the player's peer id to make them see that the command failed")
		return
	var who = split[1]
	var who_split = who.rsplit(",")
	print(split, who_split)

@rpc("call_local")
func transfer_message_to_server(message):
	var sending_player_id = multiplayer.get_remote_sender_id()
	var sending_player = get
	append_text(message)
	process_command(null, message)
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
		transfer_message_to_server(message)
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
	send_global_message(new_text)
	$TextEdit2.text = ""
	
func _input(event):
	if event.is_action_pressed("toggle_admin_panel"):
		visible = not visible
		visibleStateChanged(visible)
		if visible:
			await get_tree().create_timer(0.05).timeout
			$TextEdit2.grab_focus()
			unreadCount = 0
			return

func _unhandled_input(event):
	if visible and $TextEdit2.has_focus():
		$TextEdit2.accept_event()

func _unhandled_key_input(event):
	if visible and $TextEdit2.has_focus():
		$TextEdit2.accept_event()

