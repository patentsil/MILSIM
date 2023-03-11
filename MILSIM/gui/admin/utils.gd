extends Node
const Player = preload("res://Player.tscn")
const Character = preload("res://character.tscn")
var world = null

func getWorld():
	while not world:
		await get_tree().create_timer(0.1).timeout
	return world

func getPlayerOfPeerId(peer_id: int) -> Player:
	var world = await getWorld()
	var players = world.get_node("Players")
	for player in players.children:
		if player.PeerId == peer_id:
			return player
	return null

func getCharacterFromPlayer(player: Player) -> Character:
	return null
	
func getCharacterOfPeerId(peer_id: int) -> Character:
	var player = await getPlayerOfPeerId(peer_id)
	if not player: return null
	return player.character
	
