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

func doneChoosing():
	$btnStartClient.hide()
	$btnStartServer.hide()

func _on_btn_start_client_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer


func _on_btn_start_server_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	doneChoosing()
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.Name = "Player " + player_counter
	player.PeerId = peer_id
	player_counter += 1
	
func spawn_character(player):
	var character = Character.instantiate()
	
	
