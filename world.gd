extends Node3D

var SERVER_IP="127.0.0.1"
var SERVER_PORT=9999
var MAX_PLAYERS=3
var Player = load("res://Player.tscn")
var Character = load("res://character.tscn")
var player_counter = 0
var peer_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func del_player(id: int):
	# if not $.has_node(str(id)):
	#	return
	# $Players.get_node(str(id)).queue_free()
	pass

func _enter_tree():
	get_tree().paused = false
	get_window().title = "MILSIM Launcher"


func createWorld():
	print("Creating a new world.")
	var worldScene = load("res://world.tscn")
	var world = worldScene.instantiate()
	get_tree().get_root().add_child(world)
	return world

func characterCreatedBySpawner(character):
	print("Character was created by a spawner.")
	character.peer_id = peer_id
	pass

func get_world():
	return get_tree().root.get_node("World")

# This also means to join the game
func startGame(my_peer_id):
	var peerAuthenticating = func(id):
		print("The peer with id " + str(id) + " is authenticating.")
	peer_id = my_peer_id
	multiplayer.connect("peer_authenticating", peerAuthenticating)
	print("Starting a new game")
	# var player = add_player(my_peer_id)
	var mpSpawner = get_world().get_node("MultiplayerSpawner")
	mpSpawner.connect("spawned", characterCreatedBySpawner)
	print("Start game has finished running")
	return get_world()

func _on_btn_start_client_pressed():
	get_window().title = "MILSIM Client"
	print("A client start was intitiated")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	startGame(multiplayer.get_unique_id())
	# spawn_character(worldAndPlayer[1], worldAndPlayer[0])	
	$Menu.hide()


func _on_btn_start_server_pressed():
	print("Start server pressed")
	get_window().title = "MILSIM Server"
	print("A server start was intitiated")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	$Menu.hide()
	print("Multiplayer unique id of server is " + str(multiplayer.get_unique_id()))
	startGame(multiplayer.get_unique_id())
	
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
	# spawn_character(worldAndPlayer[1], worldAndPlayer[0])


func add_player(_peer_id):
	print("A player with the id " + str(_peer_id) + " was added.")
	var player = Player.instantiate()
	player.Name = "Player " + str(player_counter)
	player.PeerId = _peer_id
	player_counter += 1
	spawn_character(player, get_world())
	return player
	
func spawn_character(player, world):
	print("A character was spawned for " + str(player.Name))
	var character = Character.instantiate()
	character.peer_id = player.PeerId
	character.player = player
	player.character = character
	world.add_child(character, true)
	return character


func _on_btn_start_singleplayer_pressed():
	var player = add_player(1)
	get_window().title = "MILSIM Singleplayer"
	spawn_character(player, get_tree().root)
	$Menu.hide()
