extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func createCharacter():
	var CharacterClass = preload("res://character.tscn")
	var world = get_tree().get_root()
	var _character = CharacterClass.instantiate()
	world.add_child(_character)
	_character.global_position = global_position + Vector3(0, 1, 0)
	
func _ready():
	print("Trying to spawn a player")
	call_deferred("createCharacter")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
