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


func createWorld():
	var worldScene = load("res://world.tscn")
	var world = worldScene.instantiate()
	get_tree().get_root().add_child(world)
	return world

func characterCreatedBySpawner(character):
	print("Character was created by a spawner.")
	pass
	
# This also means to join the game
func startGame(my_peer_id):
	var world = createWorld()
	var player = add_player(my_peer_id)
	var mpSpawner = world.get_node("MultiplayerSpawner")
	mpSpawner.connect("spawned", characterCreatedBySpawner)
	print("Start game has finished running")
	return [world, player]
	


func hideButtons():
	$btnStartClient.hide()
	$btnStartServer.hide()

func _on_btn_start_client_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	startGame(multiplayer.get_unique_id())


func _on_btn_start_server_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	hideButtons()
	var worldAndPlayer = startGame(multiplayer.get_unique_id())
	spawn_character(worldAndPlayer[1], worldAndPlayer[0])
	
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.Name = "Player " + str(player_counter)
	player.PeerId = peer_id
	player_counter += 1
	return player
	
func spawn_character(player, world):
	var character = Character.instantiate()
	character.player = player
	player.character = character
	world.add_child(character)
	return character
	
