extends Object

func command(calling_player, players, arguments):
	var calling_char = Utils.getCharacterFromPlayer(calling_player)
	for player in players:
		var char = Utils.getCharacterFromPlayer(player)
		char.global_transform = calling_char.global_transform
