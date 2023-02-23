extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
var SERVER_IP="127.0.0.1"
var SERVER_PORT=9999
var MAX_PLAYERS=3
var Player = load("res://Player.tscn")
var Character = load("res://character.tscn")
var player_counter = 0

func _enter_tree():
	get_window().title = "MILSIM Launcher"


func createWorld():
	print("Creating a new world.")
	var worldScene = load("res://world.tscn")
	var world = worldScene.instantiate()
	get_tree().get_root().add_child(world)
	return world

func characterCreatedBySpawner(character):
	print("Character was created by a spawner.")
	pass
	
# This also means to join the game
func startGame(my_peer_id):
	var peerAuthenticating = func(id):
		print("The peer with id " + str(id) + " is authenticating.")

	multiplayer.connect("peer_authenticating", peerAuthenticating)
	print("Starting a new game")
	var world = createWorld()
	var player = add_player(my_peer_id)
	var mpSpawner = world.get_node("MultiplayerSpawner")
	mpSpawner.connect("spawned", characterCreatedBySpawner)
	print("Start game has finished running")
	return [world, player]


func hideButtons():
	visible = false

func _on_btn_start_client_pressed():
	get_window().title = "MILSIM Client"
	print("A client start was intitiated")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	startGame(multiplayer.get_unique_id())
	hideButtons()


func _on_btn_start_server_pressed():
	get_window().title = "MILSIM Server"
	print("A server start was intitiated")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	hideButtons()
	var worldAndPlayer = startGame(multiplayer.get_unique_id())
	spawn_character(worldAndPlayer[1], worldAndPlayer[0])	



func add_player(peer_id):
	print("A player with the id " + str(peer_id) + " was added.")
	var player = Player.instantiate()
	player.Name = "Player " + str(player_counter)
	player.PeerId = peer_id
	player_counter += 1
	return player
	
func spawn_character(player, world):
	print("A character was spawned for " + str(player.Name))
	var character = Character.instantiate()
	character.player = player
	player.character = character
	world.add_child(character)
	return character
	


func _on_btn_start_singleplayer_pressed():
	var singleplayer = load("res://singleplayer.tscn")
	var singleplayerScene = singleplayer.instantiate()
	get_tree().get_root().add_child(singleplayerScene)
	hideButtons()
