extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(4.0).timeout
	freeze = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	linear_velocity = Vector3()
	angular_velocity = Vector3()
