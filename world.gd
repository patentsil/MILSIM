extends Node3D

var SERVER_IP="127.0.0.1"
var SERVER_PORT=9999
var MAX_PLAYERS=3
var Player = load("res://Player.tscn")
var Character = load("res://character.tscn")
var player_counter = 0
var server_peer = null
var client_peer = null
var our_character = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func del_player(id: int):
	var char = get_character_with_peer_id(id)
	var player = get_player_with_peer_id(id)
	player.queue_free()
	char.queue_free()
	pass

func _enter_tree():
	get_tree().paused = false
	get_window().title = "MILSIM Launcher"

func _process(delta):
	pass
#	global_position = 

func createWorld():
	print("Creating a new world.")
	var worldScene = load("res://world.tscn")
	var world = worldScene.instantiate()
	get_tree().get_root().add_child(world)
	return world

func get_world():
	return get_tree().root.get_node("World")


func _on_btn_start_client_pressed():
	get_window().title = "MILSIM Client"
	print("A client start was intitiated")
	var peer = ENetMultiplayerPeer.new()
	var desiredIP = SERVER_IP
	if $Menu/VBoxContainer/leAddress.text != "":
		desiredIP = $Menu/VBoxContainer/leAddress.text
	peer.create_client(desiredIP, SERVER_PORT)
	print("Client created")
	var host = peer.host
#	host.connect("", func():
#		print("Connection was established")
#		$Menu.hide()
#		)
	client_peer = peer
	multiplayer.multiplayer_peer = peer
	var toHide = [$Menu/VBoxContainer/btnStartServer, $Menu/VBoxContainer/btnStartClient, $Menu/VBoxContainer/leAddress,
	$Menu/VBoxContainer/btnStartSingleplayer]
	var toShow = [$Menu/VBoxContainer/btnBack, $Menu/VBoxContainer/Label]
	for element in toHide:
		element.hide()
	for element in toShow:
		element.show()
	$Menu/VBoxContainer/btnBack.connect("pressed", func():
		await get_tree().create_timer(1).timeout
		for element in toHide:
			element.show()
		for element in toShow:
			element.hide()
		peer.close()
		)
	while peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_CONNECTED:
		await get_tree().create_timer(0.05).timeout
	$Menu.hide()
	

func _on_btn_start_server_pressed(is_single_player = false):
	print("Start server pressed")
	get_window().title = "MILSIM Server"
	print("A server start was intitiated")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	peer.set_refuse_new_connections(is_single_player)
	server_peer = peer
	multiplayer.multiplayer_peer = peer
	$Menu.hide()
	print("Multiplayer unique id of server is " + str(multiplayer.get_unique_id()))
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		print("Spawning already connected player " + str(id))
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		print("Spawning the local player")
		add_player(1)

func add_player(_peer_id):
	print("A player with the id " + str(_peer_id) + " was added.")
	var player = Player.instantiate()
	player.Name = "Player " + str(player_counter)
	player.PeerId = _peer_id
	player_counter += 1
	get_world().get_node("Players").add_child(player, true)
	replicatePlayer.rpc(player.Name, player.PeerId)
	spawn_character(player, get_world())
	return player

func get_player_with_peer_id(_peer_id):
	for player in $Players.get_children():
		if player.PeerId == _peer_id:
			return player

func get_character_with_peer_id(_peer_id):
	for child in get_children():
		if child is Character and child.peer_id == _peer_id:
			return child

@rpc("any_peer")
func replicatePlayer(playerName, playerPeerId):
	print("A player is being replicated.")
	var player = Player.instantiate()
	player.Name = playerName
	player.PeerId = playerPeerId
	get_world().get_node("Players").add_child(player, true)
	await get_tree().create_timer(0.3).timeout
	var char = get_character_with_peer_id(playerPeerId)
	if char:
		char.player = player
		player.character = char
	else:
		print("No character was available for replicatePlayer")
	print("Player " + player.Name + " was replicated")

func spawn_character(player, world):
	print("A character was spawned for " + str(player.PeerId))
	var character = Character.instantiate()
	character.name = player.name
	character.peer_id = player.PeerId
	character.player = player
	player.character = character
	character.global_position = get_world().get_node("Spawn").global_position + Vector3(0, 0.5, 0)
	world.add_child(character, true)
	return character


func _on_btn_start_singleplayer_pressed():
	_on_btn_start_server_pressed()
	
