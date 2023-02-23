extends Node3D

var Character = load("res://character.tscn")

func spawn_character(player, world):
	var character = Character.instantiate()
	character.player = player
	if player:
		player.character = character
	world.add_child(character)
	return character

func createWorld():
	print("Creating a new world.")
	var worldScene = load("res://world.tscn")
	var world = worldScene.instantiate()
	get_tree().get_root().add_child(world)
	return world

func _enter_tree():
	var world = createWorld()
	var char = spawn_character(null, world)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
